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
      args.each { |l| @socket.write l } if !@socket.closed?
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
    rescue SystemExit
      self.process_disconnect unless self.disconnect_processed?
      @disconnect_processed = true
    rescue Exception => e
      Marvin::ExceptionTracker.log(e)
    end
    
    def quit(*args)
      super(*args)
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
        logger.debug "Preparing to close socket"
        connection.socket.close
      end
      logger.debug "Stopped."
    end
    
    # Registers a callback handle that will be periodically run.
    def periodically(timing, event_callback)
      callback = proc { self.dispatch event_callback.to_sym }
      Thread.new do
        while true
          callback.call
          sleep timing
        end
      end
    end
    
  end
end