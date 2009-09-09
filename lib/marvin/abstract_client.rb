require 'ostruct'
require 'active_support'
require "marvin/irc/event"

module Marvin
  class AbstractClient
    
    include Marvin::Dispatchable
    
    def initialize(opts = {})
      self.original_opts    = opts.dup # Copy the options so we can use them to reconnect.
      self.server           = opts[:server]
      self.port             = opts[:port]
      self.default_channels = opts[:channels]
      self.nicks            = opts[:nicks] || []
      self.pass             = opts[:pass]
    end
    
    cattr_accessor :events, :configuration, :logger, :is_setup, :connections
    attr_accessor  :channels, :nickname, :server, :port, :nicks, :pass, :disconnect_expected, :original_opts
    
    # Set the default values for the variables
    @@events                 = []
    @@configuration          = OpenStruct.new
    @@configuration.channels = []
    @@connections            = []
    
    # Initializes the instance variables used for the
    # current connection, dispatching a :client_connected event
    # once it has finished. During this process, it will
    # call #client= on each handler if they respond to it.
    def process_connect
      self.class.setup
      logger.info "Initializing the current instance"
      @channels = []
      connections << self
      logger.info "Setting the client for each handler"
      handlers.each { |h| h.client = self if h.respond_to?(:client=) }
      logger.info "Dispatching the default :client_connected event"
      dispatch :client_connected
    end
    
    def process_disconnect
      logger.info "Handling disconnect for #{self.server}:#{self.port}"
      connections.delete(self)
      dispatch :client_disconnected
      unless @disconnect_expected
        logger.warn "Lost connection to server - adding reconnect"
        self.class.add_reconnect @original_opts
      else
        Marvin::Loader.stop! if connections.blank?
      end
    end
    
    # Sets the current class-wide settings of this IRC Client
    # to either an OpenStruct or the results of #to_hash on
    # any other value that is passed in.
    def self.configuration=(config)
      @@configuration = config.is_a?(OpenStruct) ? config : OpenStruct.new(config.to_hash)
    end
    
    def self.setup?
      @setup ||= false
    end
    
    # Initializes class-wide settings and those that
    # are required such as the logger. by default, it
    # will convert the channel option of the configuration
    # to be channels - hence normalising it into a format
    # that is more widely used throughout the client.
    def self.setup
      return if setup?
      # TODO: Handle setup here.
      @setup = true
    end
    
    ## Handling all of the the actual client stuff.
    
    def receive_line(line)
      dispatch :incoming_line, :line => line
      event = Marvin::Settings.default_parser.parse(line)
      dispatch(event.to_incoming_event_name, event.to_hash) unless event.nil?
    end
    
    # Default handlers
    
    # The default handler for all things initialization-related
    # on the client. Usually, this will send the user command,
    # set out nick, join all of the channels / rooms we wish
    # to be in and if a password is specified in the configuration,
    # it will also attempt to identify us.
    def handle_client_connected(opts = {})
      logger.info "About to handle client connected"
      # If the pass is set
      unless pass.blank?
        logger.info "Sending pass for connection"
        command :pass, pass
      end
      # IRC Connection is establish so we send all the required commands to the server.
      logger.info "Setting default nickname"
      nick nicks.shift
      logger.info "sending user command"
      command :user, configuration.user, "0", "*", Marvin::Util.last_param(self.configuration.name)
    rescue Exception => e
      Marvin::ExceptionTracker.log(e)
    end
    
    def default_channels
      @default_channels ||= []
    end
    
    def default_channels=(channels)
      @default_channels = channels.to_a.map { |c| c.to_s }
    end
    
    def host_with_port
      @host_with_port ||= "#{self.server}:#{self.port}"
    end
    
    def nicks
      if @nicks.blank? && !@nicks_loaded
        logger.info "Setting default nick list"
        @nicks = []
        @nicks << configuration.nick
        @nicks += configuration.nicks.to_a unless configuration.nicks.blank?
        @nicks.compact!
        @nicks_loaded = true
      end
      return @nicks
    end
    
    # Break it down into a couple of different files.
    require 'marvin/client/default_handlers'
    require 'marvin/client/actions'
    
  end
end