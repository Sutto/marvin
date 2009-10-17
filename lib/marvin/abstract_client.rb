require "marvin/irc/event"

module Marvin
  # An abstract class implementing (and mixing in) a lot of
  # the default functionality involved on handling an irc
  # connection.
  #
  # To provide an implementation, you must subclass and implement
  # #send_line, .add_reconnect, and any other loader etc methods.
  #
  # @see Marvin::IRC::Client
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
    #
    # @see Marvin::AbstractClient.setup
    # @see Marvin::Base#client=
    def process_connect
      self.class.setup
      logger.info "Initializing the current instance"
      @channels = []
      connections << self
      logger.info "Dispatching the default :client_connected event"
      dispatch :client_connected
    end
    
    # Handles a lost connection / disconnect, stopping the loader if it's the
    # last connection (purposely terminated) otherwise scheduling a reconnection
    #
    # @see Marvin::Loader.stop!
    def process_disconnect
      logger.info "Handling disconnect for #{host_with_port}"
      connections.delete(self)
      dispatch :client_disconnected
      if @disconnect_expected
        Marvin::Loader.stop! if connections.blank?
      else
        logger.warn "Unexpectly lost connection to server; adding reconnect"
        self.class.add_reconnect @connection_config
      end
    end
    
    # Iterates over handles and calls client= when defined. Used before dispatching
    # in order to ensure each hander has the correct client. Note that this needs
    # to be improved soon.
    def setup_handlers
      handlers.each { |h| h.client = self if h.respond_to?(:client=) }
    end
    
    # If @@development is true, We'll attempt to reload any changed files (namely,
    # handlers).s
    def process_development
      Marvin::Reloading.reload! if @@development
    end
    
    # Before dispatching, check if we need to reload and setup handlers correctly.
    def pre_dispatching
      process_development
      setup_handlers
    end
    
    # Sets the current class-wide settings of this IRC Client to
    # an instance of Marvin::Nash with the properties of a hash
    # / nash passed in.
    #
    # The new configuration will be normalized before use (namely,
    # it will convert nested items to nashes)
    #
    # @param [Marvin::Nash, Hash] config the new configuration
    def self.configuration=(config)
      config = Marvin::Nash.new(config.to_hash) unless config.is_a?(Marvin::Nash)
      @@configuration = config.normalized
    end
    
    # Check if if the cient class has been setup yet
    # @return [Boolean] is the client class setup
    def self.setup?
      @setup ||= false
    end
    
    # Conditional configure
    def self.setup
      return if setup?
      configure
    end
    
    # Configure the class - namely, merge the app-wide configuration
    # and if given a block, merge the results in.
    #
    # @yieldparam [Marvin::Nash] an empty nash
    # @yieldreturn [Marvin::Nash] any changed settings.
    def self.configure
      config = Marvin::Nash.new
      config.merge! Marvin::Settings.configuration
      if block_given?
        yield(nash = Marvin::Nash.new)
        config.merge! nash
      end
      @@configuration = config
      # Help is only currently available on an instance NOT running the distributed handler.
      Marvin::CoreCommands.register! unless Marvin::Distributed::Handler.registered?
      @setup = true
    end
    
    ## Handling all of the the actual client stuff.
    
    # Receives a raw line (without EOL characters) and dispatch the
    # incoming_line event. Once that's done, parse the line and
    # dispatch an event if present.
    #
    # @param [String] line the incoming line
    def receive_line(line)
      dispatch :incoming_line, :line => line
      event = Marvin::Settings.parser.parse(line)
      dispatch(event.to_incoming_event_name, event.to_hash) unless event.nil?  
    end
    
    # Returns a list of default channels to join on connect
    # @return [Array<String>] an array of channel names that are joined on connect
    def default_channels
      @default_channels ||= []
    end
    
    # Sets the list of default channels to join
    # @param [Array<String>] channels the array of channel names
    def default_channels=(channels)
      @default_channels = channels.to_a.map { |c| c.to_s }
    end
    
    # Returns the irc server and port
    # @return [String] server port in "server:port" format
    def host_with_port
      @host_with_port ||= "#{server}:#{port}"
    end
    
    # Returns a list available nicks / nicks to try
    # on connect.
    # @return [Array<String>] The array of nicks
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