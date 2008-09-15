require 'socket'

module Marvin::IRC
  class SocketClient < Marvin::AbstractClient
    attr_accessor :socket
    
    def run
      @socket = TCPSocket.new(self.configuration.server, self.configuration.port)
      self.process_connect
      self.enter_loop
    end
    
    def send_line(*args)
      args.each { |l| @socket.write l }
    end
    
    def disconnect_processed?
      @disconnect_processed
    end
    
    def enter_loop
      until @socket.closed?
        line = @socket.readline.strip
        receive_line line
      end
      self.process_disconnect unless self.disconnect_processed?
      @disconnect_processed = true
    rescue EOFError
      self.process_disconnect unless self.disconnect_processed?
      @disconnect_processed = true
    end
    
    def quit(*args)
      super(*args)
      @socket.close
      self.process_disconnect unless self.disconnect_processed?
      @disconnect_processed = true
    end
    
    ## Client specific details
    
    def self.run
      self.setup # So we have options etc
      logger.debug "Connecting to #{self.configuration.server}:#{self.configuration.port}"
      self.new.run
    end
    
    def self.stop
      logger.debug "Telling all connections to quit"
      self.connections.each do |connection|
        connection.quit
      end
      logger.debug "Stopped."
    end
    
    # Registers a callback handle that will be periodically run.
    def periodically(timing, event_callback)
      callback = proc { self.dispatch_event event_callback.to_sym }
    end
    
  end
end