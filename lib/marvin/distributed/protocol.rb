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
      
      def handle_response(response)
        logger.debug "Handling response in distributed protocol (response => #{response.inspect})"
        return unless response.is_a?(Hash) && response.has_key?("message")
        options = response["options"] || {}
        process_response_message(response["message"], options)
      end
      
      def host_with_port
        @host_with_port ||= begin
          port, ip = Socket.unpack_sockaddr_in(get_peername)
          "#{ip}:#{port}"
        end
      end
      
      protected
      
      def options_for_callback(blk)
        return {} if blk.blank?
        cb_id = "callback-#{seld.object_id}-#{Time.now.to_f}"
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
          callback.call(self, hash)
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
      
    end
  end
end