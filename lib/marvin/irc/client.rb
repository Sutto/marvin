require 'eventmachine'

module Marvin::IRC
  class Client < Marvin::AbstractClient
    
    @@stopped = false
    
    attr_accessor :em_connection
    
    class EMConnection < EventMachine::Protocols::LineAndTextProtocol
      is :loggable
      
      attr_accessor :client, :server, :port
      
      def initialize(*args)
        opts = args.extract_options!
        super(*args)
        self.client = Marvin::IRC::Client.new(opts)
        self.client.em_connection = self
      end
      
      def post_init
        super
        process_connect
      end

      def unbind
        process_disconnect
        super
      end
      
      def receive_line(line)
        logger.debug "<< #{line.strip}"
        self.client
      end
      
    end

    def send_line(*args)
      args.each { |line| Marvin::Logger.debug ">> #{line.strip}" }
      em_connection.send_data *args
    end
    
    ## Client specific details
    
    # Starts the EventMachine loop and hence starts up the actual
    # networking portion of the IRC Client.
    def self.run(force = false)
      return if self.stopped && !force
      self.setup # So we have options etc
      settings = YAML.load_file(Marvin::Settings.root / "config" / "connections.yml")
      if settings.is_a?(Hash)
        # Use epoll if available
        EventMachine.epoll
        EventMachine.run do
          settings.each do |name, options|
            settings = options.symbolize_keys!
            settings[:server] ||= name
            settings.reverse_merge!(:port => 6667, :channels => [])
            connect settings
          end
          @@stopped = false
        end
      else
        logger.fatal "config/connections.yml couldn't be loaded. Exiting"
      end
    end
    
    def self.connect(opts = {})
      logger.info "Connecting to #{opts[:server]}:#{opts[:port]} - Channels: #{opts[:channels].join(", ")}"
      EventMachine.connect(opts[:server], opts[:port], EMConnection, opts)
    end
    
    def self.stop
      return if @@stopped
      logger.debug "Telling all connections to quit"
      connections.dup.each { |connection| connection.quit }
      logger.debug "Telling Event Machine to Stop"
      EventMachine.stop_event_loop
      logger.debug "Stopped."
      @@stoped = true
    end
    
    def self.add_reconnect(opts = {})
      logger.warn "Adding entry to reconnect to #{opts[:server]}:#{opts[:port]} in 15 seconds"
      EventMachine.add_timer(15) do
        logger.warn "Attempting to reconnect to #{opts[:server]}:#{opts[:port]}"
        connect(opts)
      end
    end
    
    # Registers a callback handle that will be periodically run.
    def periodically(timing, event_callback)
      EventMachine.add_periodic_timer(timing) { dispatch(event_callback.to_sym) }
    end
    
  end
  
end