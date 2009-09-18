require 'json'
require 'digest/sha2'
require 'eventmachine'
require 'socket'

module Marvin
  module Distributed
    class Server < Protocol
      
      register_handler_method :completed
      register_handler_method :exception
      register_handler_method :action
      register_handler_method :authenticate
      
      cattr_accessor :free_connections, :action_whitelist
      self.free_connections = []
      self.action_whitelist = [:nick, :pong, :action, :msg, :quit, :part, :join, :command]
      
      attr_accessor :processing, :configuration
      
      def initialize(*args)
        @configuration = args.last.is_a?(Marvin::Nash) ? args.pop : Marvin::nash.new
        super(*args)
      end
      
      def post_init
        @callbacks = {}
        logger.info "Got distributed client connection with #{self.host_with_port}"
        if should_use_ssl?
          handle_enable_ssl
        else
          @connected = true
          post_connect
        end
      end
      
      def post_connect
        logger.debug "Remote client available, welcoming"
        send_message(:welcome)
        complete_processing
      end
      
      def unbind
        logger.info "Lost distributed client connection with #{self.host_with_port}"
        @@free_connections.delete(self)
        super
      end
      
      def dispatch(client, name, options)
        @processing = true
        send_message(:event, {
          "event-name"    => name.to_s,
          "event-options" => options,
          "client-host"   => client.host_with_port,
          "client-nick"   => client.nickname
        })
      end
      
      def handle_authenticate(options = {})
        return unless requires_auth?
        logger.info "Attempting authentication for distributed client"
        if options["token"].present? && options["token"] == configuration.token
          @authenticated = true
          send_message(:authenticated)
        else
          send_message(:authentication_failed)
        end
      end
      
      def handle_completed(options = {})
        return if fails_auth!
        logger.debug "Completed message from #{self.host_with_port}"
        complete_processing
      end
      
      def handle_exception(options = {})
        return if fails_auth!
        logger.info "Handling exception on #{self.host_with_port}"
        name      = options["name"]
        message   = options["message"]
        backtrace = options["backtrace"]
        logger.warn "Error in remote client - #{name}: #{message}"
        [*backtrace].each { |line| logger.warn "--> #{line}" } if backtrace.present?
      end
      
      def handle_action(options = {})
        return if fails_auth!
        logger.debug "Handling action from on #{self.host_with_port}"
        target    = lookup_client_for(options["client-host"])
        action    = options["action"]
        arguments = [*options["arguments"]]
        return if target.blank? || action.blank?
        begin
          a = action.to_sym
          if self.action_whitelist.include?(a) && target.respond_to?(a)
            res = target.send(a, *arguments)
            if @callback_id.present? && res.respond_to?(:to_json)
              send_message_reply(:noop, {"return-value" => res.to_json})
            end
          else
            logger.warn "Client attempted invalid action #{a.inspect}"
          end
        rescue Exception => e
          Marvin::ExceptionTracker.log(e)
        end
      end
      
      def complete_processing
        @@free_connections << self
        @processing = false
      end
      
      def start_processing
        @processing = true
      end
      
      def lookup_client_for(key)
        Marvin::IRC::Client.connections.detect do |c|
          c.host_with_port == key
        end
      end
      
      def requires_auth?
        configuration.token? && !authenticated?
      end
      
      def authenticated?
        @authenticated ||= false
      end
      
      def fails_auth!
        if requires_auth?
          logger.debug "Authentication missing for distributed client"
          send_message(:unauthorized)
          close_connection_after_writing
          return true
        end
      end
      
      def self.start
        opts = Marvin::Settings.distributed || Marvin::Nash.new
        opts = opts.server || Marvin::Nash.new
        host = opts.host  || "0.0.0.0"
        port = (opts.port || 8943).to_i
        logger.info "Starting distributed server on #{host}:#{port} (requires authentication = #{opts.token?})"
        EventMachine.start_server(host, port, self, opts)
      end
      
      def self.next
        @@free_connections.shift
      end
      
    end
  end
end