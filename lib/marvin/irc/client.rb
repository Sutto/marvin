require 'eventmachine'

module Marvin::IRC
  
  # == Marvin::IRC::Client
  # An EventMachine protocol implementation built to
  # serve as a basic, single server IRC client.
  #
  # Operates on the principal of Events as well
  # as handlers.
  #
  # === Events
  # Events are things that can happen (e.g. an
  # incoming message). All outgoing events are
  # automatically handled from within the client
  # class. Incoming events are currently based
  # on regular expression based matches of
  # incoming messages. the Client#register_event
  # method takes either an instance of Marvin::IRC::Event
  # or a set of arguments which will then be used
  # in the constructor of a new Marvin::IRC::Event
  # instance (see, for example, the source code for
  # this class for examples).
  #
  # === Handlers
  # Handlers on the other hand do as the name suggests
  # - they listen for dispatched events and act accordingly.
  # Handlers are simply objects which follow a certain
  # set of guidelines. Typically, a handler will at
  # minimum respond to #handle(event_name, details)
  # where event_name is a symbol for the current
  # event (e.g. :incoming_event) whilst details is a
  # a hash of details about the current event (e.g.
  # message target and the message itself).
  #
  # ==== Getting the current client instance
  # If the object responds to client=, The client will
  # call it with the current instance of itself
  # enabling the handler to do things such as respond.
  # Also, if a method handle_[message_name] exists,
  # it will be called instead of handle.
  #
  # ==== Adding handlers
  # To add an object as a handler, you simply call
  # the class method, register_handler with the
  # handler as the only argument.
  class Client < Marvin::AbstractClient
    cattr_accessor :stopped
    attr_accessor :em_connection
    
    class EMConnection < EventMachine::Protocols::LineAndTextProtocol
      attr_accessor :client, :server, :port
      
      def initialize(*args)
        opts = args.extract_options!
        super(*args)
        self.client = Marvin::IRC::Client.new(opts)
        self.client.em_connection = self
      end
      
      def post_init
        client.process_connect
        super
      end

      def unbind
        client.process_disconnect
        super
      end
      
      def receive_line(line)
        Marvin::Logger.debug "<< #{line.strip}"
        self.client.receive_line(line)
      end
      
    end

    def send_line(*args)
      args.each { |line| Marvin::Logger.debug ">> #{line.strip}" }
      em_connection.send_data *args
    end
    
    ## Client specific details
    
    # Starts the EventMachine loop and hence starts up the actual
    # networking portion of the IRC Client.
    def self.run
      self.setup # So we have options etc
      settings = YAML.load_file(Marvin::Settings.root / "config/connections.yml")
      if settings.is_a?(Hash)
        EventMachine.epoll
        EventMachine::run do
          settings.each do |name, options|
            settings = options.symbolize_keys!
            settings[:server] ||= name
            settings.reverse_merge!(:port => 6667, :channels => [])
            connect settings
          end
        end
      else
        logger.fatal "config/connections.yml couldn't be loaded. Exiting"
      end
    end
    
    def self.connect(opts = {})
      logger.info "Connecting to #{opts[:server]}:#{opts[:port]} - Channels: #{opts[:channels].join(", ")}"
      EventMachine::connect(opts[:server], opts[:port], EMConnection, opts)
      logger.info "Connection created for #{opts[:server]}:#{opts[:port]}"
    end
    
    def self.stop
      return if self.stopped
      logger.debug "Telling all connections to quit"
      self.connections.dup.each { |connection| connection.quit }
      logger.debug "Telling Event Machine to Stop"
      EventMachine::stop_event_loop
      logger.debug "Stopped."
      self.stopped = true
    end
    
    def self.add_reconnect(opts = {})
      Marvin::Logger.warn "Adding entry to reconnect to #{opts[:server]}:#{opts[:port]} in 15 seconds"
      EventMachine::add_timer(15) do
        Marvin::Logger.warn "Attempting to reconnect to #{opts[:server]}:#{opts[:port]}"
        Marvin::IRC::Client.connect(opts)
      end
    end
    
    # Registers a callback handle that will be periodically run.
    def periodically(timing, event_callback)
      callback = proc { self.dispatch event_callback.to_sym }
      EventMachine::add_periodic_timer(timing, &callback)
    end
    
  end
  
end