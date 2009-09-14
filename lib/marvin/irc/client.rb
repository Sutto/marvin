require 'eventmachine'

module Marvin::IRC
  class Client < Marvin::AbstractClient
    
    @@stopped = false
    
    attr_accessor :em_connection
    
    class EMConnection < EventMachine::Protocols::LineAndTextProtocol
      is :loggable
      
      attr_accessor :client, :port
      
      def initialize(*args)
        config = args.last.is_a?(Marvin::Nash) ? args.pop : Marvin::Nash.new
        super(*args)
        @client = Marvin::IRC::Client.new(config)
        @client.em_connection = self
      end
      
      def post_init
        super
        @client.process_connect
      end

      def unbind
        @client.process_disconnect
        super
      end
      
      def receive_line(line)
        line = line.strip
        logger.debug "<< #{line}"
        @client.receive_line(line)
      rescue Exception => e
        logger.warn "Uncaught exception raised; Likely in Marvin"
        Marvin::ExceptionTracker.log(e)
      end
      
      def send_line(*lines)
        lines.each do |l|
          logger.debug ">> #{line.strip}"
          em_connection.send_data line
        end
      end
      
    end
    
    ## Client specific details
    
    class << self
      
      def send_line(*args)
        @em_connection.send_line(*args)
      end
      
      # Starts the EventMachine loop and hence starts up the actual
      # networking portion of the IRC Client.
      def run(force = false)
        return if @stopped && !force
        self.setup # So we have options etc
        connections_file = Marvin::Settings.root / "config" / "connections.yml"
        connections = Marvin::Nash.load_file(connections_file) rescue nil
        if connections.present?
          # Use epoll if available
          EventMachine.epoll
          EventMachine.run do
            connections.each_pair do |server, configuration|
              connect(configuration.merge(:server => server.to_s))
            end
            @@stopped = false
          end
        else
          logger.fatal "config/connections.yml couldn't be loaded."
        end
      end

      def connect(c, &blk)
        c = normalize_connection_options(c)
        raise ArgumentError, "Your connection options must specify a server" if !c.server?
        raise ArgumentError, "Your connection options must specify a port"   if !c.port?
        real_block = blk.present? ? proc { |c| blk.call(connection.client) } : nil
        logger.info "Connecting to #{c.server}:#{c.port} - Channels: #{c.channels.join(", ")}"
        EventMachine.connect(c.server, c.port, EMConnection, c, &real_block)
      end

      def stop
        return if @@stopped
        logger.debug "Telling all connections to quit"
        connections.dup.each { |connection| connection.quit }
        logger.debug "Telling Event Machine to Stop"
        EventMachine.stop_event_loop
        logger.debug "Stopped."
        @@stoped = true
      end

      def add_reconnect(c)
        logger.warn "Adding timer to reconnect to #{c.server}:#{c.port} in 15 seconds"
        EventMachine.add_timer(15) do
          logger.warn "Preparing to reconnect to #{c.server}:#{c.port}"
          connect(c)
        end
      end
      
      protected
      
      def normalize_connection_options(config)
        config = Marvin::Nash.new(config) if !config.is_a?(Marvin::Nash)
        config = config.normalized
        channels = config.channels
        if channels.present?
          config.channels = [*channels].compact.reject { |c| c.blank? }
        else
          config.channels = []
        end
        return config
      end
      
    end
    
    # Registers a callback handle that will be periodically run.
    def periodically(timing, event_callback)
      EventMachine.add_periodic_timer(timing) { dispatch(event_callback.to_sym) }
    end
    
  end
  
end