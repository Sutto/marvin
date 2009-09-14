require 'json'
require 'digest/sha2'

module Marvin
  module Distributed
    class Server < EventMachine::Connection
      is :loggable
      
      cattr_accessor :free_connections
      self.free_connections = []
      
      attr_accessor :last_request, :processing, :callbacks
      
      def receive_line(line)
        response = JSON.parse(line)
        handle_response(response)
      rescue JSON::ParserError
      rescue Exception => e
        Marvin::ExceptionTracker.log(e)
      end
      
      def send_message(name, arguments, &callback)
        payload = {
          "message"  => name.to_s,
          "options"  => arguments,
          "sent-at"  => Time.now
        }
        payload.merge!(options_for_callback(callback))
        send_data "#{JSON.dump(payload)}\n"
      end
      
      def handle_response(response)
        return unless response.is_a?(Hash) && response.has_key?("message")
        options = response["options"] || {}
        process_callback(response)
        case response["message"]
          when "completed"
            handle_completed(options)
          when "exception"
            handle_exception(options)
          when "action"
            handle_action(options)
        end
      end
      
      def dispatch(client, name, options)
        @processing = true
        send_message(:event, {
          "event-name"    => name,
          "event-options" => options,
          "client"        => client.host_with_port
        })
      end
      
      def handle_completed(options = {})
        complete_processing
      end
      
      def handle_exception(options = {})
        name      = options["name"]
        message   = options["message"]
        backtrace = options["backtrace"]
        logger.warn "Error in remote client - #{name}: #{message}"
        [*backtrace].each { |line| logger.warn "--> #{line}" } if backtrace.present?
      end
      
      def handle_action(options = {})
        server    = lookup_client_for(options["client"])
        action    = options["action"]
        arguments = [*options["arguments"]]
        return if server.blank? || action.blank?
        begin
          a = action.to_sym
          server.send(a, *arguments) if server.respond_to?(a)
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
      
      def options_for_callback(blk)
        return {} if blk.blank?
        cb_id = "callback-#{seld.object_id}-#{Time.now.to_f}"
        count = 0
        count += 1 while @callbacks.has_key?(Digest::SHA256.hexdigest("#{cb_id}-#{count}"))
        final_id = Digest::SHA256.hexdigest("#{cb_id}-#{count}")
        @callbacks[final_id] = blk
        {"callback-id" => final_id}
      end
      
      def process_callback(hash)
        if hash.is_a?(Hash) && hash.has_key?("callback-id")
          callback = @callbacks.delete(hash["callback-id"])
          callback.call(self, hash)
        end
      end
      
      def self.start
      end
      
      def self.stop
      end
      
      def self.next
        @@free_connections.shift
      end
      
    end
  end
end