require 'json'
require 'digest/sha2'
require 'eventmachine'
require 'socket'

module Marvin
  module Distributed
    class Client < Marvin::AbstractClient
      
      attr_accessor :em_connection, :remote_client_host, :remote_client_nick
      
      class RemoteClientProxy
        is :loggable
        
        def initialize(conn, host_with_port, nickname)
          @connection     = conn
          @host_with_port = host_with_port
          @nickname       = nickname
        end
        
        def nickname
          @nickname
        end
        
        def host_with_port
          @host_with_port
        end
        
        def method_missing(name, *args)
          logger.debug "Proxying #{name}(#{args.inspect[1..-2]}) to #{@host_with_port}"
          @connection.send_message(:action, {
            "action"      => name.to_s,
            "arguments"   => args,
            "client-host" => @host_with_port
          })
        end
        
      end
      
      class EMConnection < Marvin::Distributed::Protocol
        
        register_handler_method :event
        register_handler_method :authentication_failed
        register_handler_method :authenticated
        register_handler_method :unauthorized
        register_handler_method :welcome
        
        cattr_accessor :stopping
        self.stopping = false
        
        attr_accessor :client, :port, :connection_host, :connection_port, :configuration

        def initialize(*args)
          @configuration = args.last.is_a?(Marvin::Nash) ? args.pop : Marvin::Nash.new
          super(*args)
          @callbacks = {}
          @client = Marvin::Distributed::Client.new(self)
          @authenticated = false
        end

        def post_init
          super
          logger.info "Connected to distributed server"
        end
        
        def post_connect
          logger.info "Connection started; processing authentication"
          process_authentication
        end
        
        def unbind
          if self.stopping
            logger.info "Stopping distributed client"
          else
            logger.info "Lost connection to distributed client - Scheduling reconnect"
            EventMachine.add_timer(15) { EMConnection.connect(connection_host, connection_port, @configuration) }
          end
          super
        end
        
        def process_authentication
          if configuration.token?
            logger.info "Attempting to authenticate..." 
            send_message(:authenticate, {:token => configuration.token})
          end
        end
        
        def handle_welcome(options = {})
          if should_use_ssl? && !ssl_enabled?
            request_ssl!
          else
            @connected = true
            post_connect
          end
        end
        
        def handle_event(options = {})
          event       = options["event-name"]
          client_host = options["client-host"]
          client_nick = options["client-nick"]
          options     = options["event-options"]
          options     = {} unless options.is_a?(Hash)
          return if event.blank?
          begin
            logger.debug "Handling #{event}"
            @client.remote_client_host = client_host
            @client.remote_client_nick = client_nick
            @client.setup_handlers
            @client.dispatch(event.to_sym, options)
          rescue Exception => e
            logger.warn "Got Exception - Forwarding to Remote"
            Marvin::ExceptionTracker.log(e)
            send_message(:exception, {
              "name"      => e.class.name,
              "message"   => e.message,
              "backtrace" => e.backtrace
            })
          ensure
            logger.debug "Sending completed message"
            send_message(:completed)
            @client.reset!
          end
        end
        
        def handle_unauthorized(options = {})
          logger.warn "Attempted action when unauthorized. Stopping client."
          Marvin::Distributed::Client.stop
        end
        
        def handle_authenticated(options = {})
          @authenticated = true
          logger.info "Successfully authenticated with #{host_with_port}"
        end
        
        def handle_authentication_failed(options = {})
          logger.info "Authentication with #{host_with_port} failed. Stopping."
          Marvin::Distributed::Client.stop
        end
        
        def self.connect(host, port, config = Marvin::Nash.new)
          logger.info "Attempting to connect to #{host}:#{port}"
          EventMachine.connect(host, port, self, config) do |c|
            c.connection_host = host
            c.connection_port = port
          end
        end
        
        def request_ssl!
          logger.info "Requesting SSL for Distributed Client"
          send_message(:enable_ssl) unless ssl_enabled?
        end

      end
   
      def initialize(em_connection)
        @em_connection = em_connection
      end
   
      def remote_client
        @remote_client ||= RemoteClientProxy.new(@em_connection, @remote_client_host, @remote_client_nick)
      end
      
      def reset!
        @remote_client = nil
        @remote_client_nick = nil
        @remote_client_host = nil
        reset_handlers
      end
      
      def setup_handlers
        self.class.handlers.each { |h| h.client = remote_client if h.respond_to?(:client=) }
      end
      
      def reset_handlers
        self.class.handlers.each { |h| h.client = nil if h.respond_to?(:client=) }
      end
      
      class << self
        
        def run
          logger.info "Preparing to start distributed client"
          EventMachine.kqueue
          EventMachine.epoll
          EventMachine.run do
            opts = Marvin::Settings.distributed || Marvin::Nash.new
            opts = opts.client || Marvin::Nash.new
            host = opts.host  || "0.0.0.0"
            port = (opts.port || 8943).to_i
            EMConnection.connect(host, port, opts)
          end
        end
        
        def stop
          logger.info "Stopping distributed client..."
          EMConnection.stopping = true
          EventMachine.stop_event_loop
        end
        
      end
      
    end
  end
end