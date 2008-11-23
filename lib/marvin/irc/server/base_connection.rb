require 'eventmachine'

module Marvin
  module IRC
    module Server
      class BaseConnection < EventMachine::Protocols::LineAndTextProtocol
        
        attr_accessor :port, :host, :started_at
        
        # Our initialize method
        def initialize(opts = {})
          super
          @buffer = []
          @port = opts[:port]
          @host = opts[:host]
          @started_at = opts[:started_at] || Time.now
        end
        
        attr_accessor :connection_implementation, :buffer
        
        # Receive the line, processing as it needs to be.
        # Not that we have a conditional check to setup
        # the correct connection
        def receive_line(line)
          if !@connection_implementation.nil?
            @connection_implementation.receive_line(line)
          elsif line[0..3] == "USER"
            @buffer << line
            self.connection_implementation = UserConnection.new(self, @buffer)
            @buffer = nil
          elsif line[0..5] == "SERVER"
            @buffer << line
            self.connection_implementation = ServerConnection.new(self, @buffer)
            @buffer = nil
          else
            @buffer << line
          end
        end
        
        def send_line(line)
          line += "\r\n" unless line[-2..-1] == "\r\n"
          send_data line
        end
        
        def kill_connection!
          close_connection_after_writing
        end
        
        # Do things on the unbind
        def unbind
          super # Call the old version
          @connection_implementation.process_disconnect
        end
        
        # Do things on the connection implementation
        def post_init
          super
        end
        
      end
    end
  end
end