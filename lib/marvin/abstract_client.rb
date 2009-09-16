require "marvin/irc/event"

module Marvin
  class AbstractClient
    
    is :dispatchable, :loggable
    
    def initialize(opts)
      opts = opts.to_nash if opts.is_a?(Hash)
      @connection_config = opts.dup # Copy the options so we can use them to reconnect.
      @server            = opts.server
      @port              = opts.port
      @default_channels  = opts.channels
      @nicks             = opts.nicks || []
      @pass              = opts.pass
    end
    
    cattr_accessor :events, :configuration, :is_setup, :connections, :development
    attr_accessor  :channels, :nickname, :server, :port, :nicks, :pass,
                   :disconnect_expected, :connection_config
    
    # Set the default values for the variables
    @@events        = []
    @@configuration = Marvin::Nash.new
    @@connections   = []
    @@development   = false
      
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
      setup_handlers
      logger.info "Dispatching the default :client_connected event"
      dispatch :client_connected
    end
    
    def process_disconnect
      logger.info "Handling disconnect for #{host_with_port}"
      connections.delete(self)
      dispatch :client_disconnected
      unless @disconnect_expected
        logger.warn "Unexpectly lost connection to server; adding reconnect"
        self.class.add_reconnect @connection_config
      else
        Marvin::Loader.stop! if connections.blank?
      end
    end
    
    def setup_handlers
      handlers.each { |h| h.client = self if h.respond_to?(:client=) }
    end
    
    def process_development
      if @@development
        Marvin::Reloading.reload!
        setup_handlers
      end
    end
    
    def dispatch(*args)
      process_development
      super
    end
    
    # Sets the current class-wide settings of this IRC Client
    # to either an OpenStruct or the results of #to_hash on
    # any other value that is passed in.
    def self.configuration=(config)
      config = Marvin::Nash.new(config.to_hash) unless config.is_a?(Marvin::Nash)
      @@configuration = config.normalized
    end
    
    def self.setup?
      @setup ||= false
    end
    
    def self.setup
      return if setup?
      configure
    end
    
    def self.configure
      config = Marvin::Nash.new
      config.merge! Marvin::Settings.configuration
      if block_given?
        yield(nash = Marvin::Nash.new)
        config.merge! nash
      end
      @@configuration = config
      # Help is only currently available on an instance running
      # distributed handler.
      Marvin::CoreCommands.register! unless Marvin::Distributed::Handler.registered?
      @setup = true
    end
    
    ## Handling all of the the actual client stuff.
    
    def receive_line(line)
      dispatch :incoming_line, :line => line
      event = Marvin::Settings.parser.parse(line)
      dispatch(event.to_incoming_event_name, event.to_hash) unless event.nil?  
    end
    
    def default_channels
      @default_channels ||= []
    end
    
    def default_channels=(channels)
      @default_channels = channels.to_a.map { |c| c.to_s }
    end
    
    def host_with_port
      @host_with_port ||= "#{server}:#{port}"
    end
    
    def nicks
      if @nicks.blank? && !@nicks_loaded
        logger.info "Setting default nick list"
        @nicks = []
        @nicks << configuration.nick if configuration.nick?
        @nicks += configuration.nicks.to_a if configuration.nicks?
        @nicks.compact!
        raise "No initial nicks for #{host_with_port}" if @nicks.blank?
        @nicks_loaded = true
      end
      return @nicks
    end
    
    # Break it down into a couple of different files.
    require 'marvin/client/default_handlers'
    require 'marvin/client/actions'
    
    protected
    
    def util
      Marvin::Util
    end
    
  end
end