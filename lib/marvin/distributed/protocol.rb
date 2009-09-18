module Marvin
  module Distributed
    class Protocol < EventMachine::Protocols::LineAndTextProtocol
      is :loggable
      
      class_inheritable_accessor :handler_methods
      self.handler_methods = {}
      
      attr_accessor :callbacks
      
      def receive_line(line)
        line.strip!
        logger.debug "<< #{line}"
        response = JSON.parse(line)
        handle_response(response)
      rescue JSON::ParserError
        logger.debug "JSON parsing error for #{line.inspect}"
      rescue Exception => e
        Marvin::ExceptionTracker.log(e)
      end
      
      def send_message(name, arguments = {}, &callback)
        logger.debug "Sending #{name.inspect} to #{self.host_with_port}"
        payload = {
          "message" => name.to_s,
          "options" => arguments,
          "sent-at" => Time.now
        }
        payload.merge!(options_for_callback(callback))
        payload = JSON.dump(payload)
        logger.debug ">> #{payload}"
        send_data "#{payload}\n"
      end
      
      def send_message_reply(name, arguments = {})
        arguments["callback-id"] = @callback_id if @callback_id.present?
        send_message(name, arguments)
      end
      
      def handle_response(response)
        logger.debug "Handling response in distributed protocol (response: #{response.inspect})"
        return unless response.is_a?(Hash) && response.has_key?("message")
        options = response["options"] || {}
        @callback_id = response.delete("callback-id")
        process_callback(options)
        process_response_message(response["message"], options)
        @callback_id = nil
      end
      
      def host_with_port
        @host_with_port ||= begin
          port, ip = Socket.unpack_sockaddr_in(get_peername)
          "#{ip}:#{port}"
        end
      end
      
      def handle_enable_ssl(opts = {})
        send_message_reply(:enabled_ssl)
        enable_ssl
      end
      
      def handle_enabled_ssl(opts = {})
        enable_ssl
      end
      
      def handle_noop(opts = {})
        # DO NOTHING.
        logger.debug "no-op"
      end
      
      # After the connection is made and / or ssl is enabled.
      def post_connect
      end
      
      def ssl_handshake_completed
        logger.debug "SSL Handshake completed"
        if !connected?
          @connected = true
          post_connect
        end
      end
      
      protected
      
      def should_use_ssl?
        @should_use_ssl ||= configuration.ssl?
      end
      
      def ssl_enabled?
        instance_variable_defined?(:@ssl_enabled) && @ssl_enabled
      end
      
      def enable_ssl
        return if ssl_enabled?
        logger.debug "Enabling SSL"
        start_tls
        @ssl_enabled = true
      end
      
      def options_for_callback(blk)
        return {} if blk.blank?
        cb_id = "callback-#{self.object_id}-#{Time.now.to_f}"
        count = 0
        count += 1 while @callbacks.has_key?(Digest::SHA256.hexdigest("#{cb_id}-#{count}"))
        final_id = Digest::SHA256.hexdigest("#{cb_id}-#{count}")
        @callbacks ||= {}
        @callbacks[final_id] = blk
        {"callback-id" => final_id}
      end
      
      def process_callback(hash)
        @callbacks ||= {}
        if hash.is_a?(Hash) && hash.has_key?("callback-id")
          callback = @callbacks.delete(hash["callback-id"])
          callback.call(self, hash) if callback.present?
        end
      end
      
      def process_response_message(message, options)
        method = self.handler_methods[message.to_s]
        if method.present? && respond_to?(method)
          logger.debug "Dispatching #{message} to #{method}"
          send(method, options)
        else
          logger.warn "Got unknown message (#{message}) with options: #{options.inspect}"
        end
      end
      
      def self.register_handler_method(name, method = nil)
        name = name.to_s
        method ||= "handle_#{name}".to_sym
        self.handler_methods[name] = method
      end
      
      # Default Handlers
      register_handler_method :enable_ssl
      register_handler_method :enabled_ssl
      register_handler_method :noop
      
      def connected?
        instance_variable_defined?(:@connected) && @connected
      end
      
    end
  end
end