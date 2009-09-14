require 'json'
require 'digest/sha2'
require 'eventmachine'
require 'socket'

module Marvin
  module Distributed
    class Client < Marvin::AbstractClient
      
      attr_accessor :em_connection, :remote_client_host, :remote_client_nick
      
      class RemoteClientProxy
        
        def initialize(conn, host_with_port, nickname)
          @connection     = conn
          @host_with_port = client
          @nickname       = nickname
        end
        
        def nickname
          @nickname
        end
        
        def host_with_port
          @host_with_port
        end
        
        def method_missing(name, *args)
          logger.debug "Proxying #{name}(#{args.inspect[1..-1]}) to #{@host_with_port}"
          conn.send_message(:action, {
            "action"      => name.to_s,
            "arguments"   => args,
            "client-host" => @host_with_port
          })
        end
        
      end
      
      class EMConnection < EventMachine::Protocols::LineAndTextProtocol
        is :loggable

        attr_accessor :client, :port        

        def initialize(*args)
          config = args.last.is_a?(Marvin::Nash) ? args.pop : Marvin::Nash.new
          super(*args)
          @callbacks = {}
          @client = Marvin::Distributed::Client.new(self)
        end

        def receive_line(line)
          line.strip!
          logger.debug "<< #{line}"
          response = JSON.parse(line)
          handle_response(response)
        rescue JSON::ParserError
          logger.warn "Error parsing input: #{line}"
        rescue Exception => e
          logger.warn "Uncaught exception raised; Likely in Marvin"
          Marvin::ExceptionTracker.log(e)
        end

        def send_message(name, arguments, &callback)
          logger.debug "Sending #{name.inspect} to #{self.host_with_port}"
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
          when "event"
            handle_event(options)
          end
        end
        
        def handle_event(options = {})
          event = options["event-name"]
          client_host = options["client-host"]
          client_nick = options["client-nick"]
          options = options["event-options"]
          options = {} unless options.is_a?(Hash)
          return if event.blank?
          begin
            logger.debug "Handling #{event}"
            @client.remote_client_host = client_host
            @client.remote_client_nick = client_nick
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
        
        protected
        
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

        def host_with_port
          @host_with_port ||= begin
            port, ip = Socket.unpack_sockaddr_in(get_peername)
            "#{ip}:#{port}"
          end
        end

      end
   
      def initialize(em_connection)
        @em_connection = em_connection
      end
   
      def client
        @client ||= RemoteClientProxy.new(@em_connection, @remote_client_host, @remote_client_nick)
      end
      
      def reset!
        @client = nil
        @remote_client_nick = nil
        @remote_client_host = nil
      end
      
      class << self
        
        def run
          EventMachine.kqueue
          EventMachine.epoll
          EventMachine.run do
          end
        end
        
        def stop
          EventMachine.stop_event_loop
        end
        
      end
      
    end
  end
end