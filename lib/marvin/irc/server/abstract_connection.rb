module Marvin::IRC::Server
  class AbstractConnection
    include Marvin::Dispatchable
    
    cattr_accessor :connections
    self.connections = []
    
    attr_accessor :connection
    
    # Create a new connection with a given parent
    # and an incoming buffer of messages
    def initialize(parent, buffer = [])
      @connection = parent
      buffer.each { |line| receive_line(line) }
    end
  
    def receive_line(line)
    end
    
    def send_line(line)
      @connection.send_line(line)
    end
    
    def process_connect
    end
    
    def process_disconnect
      @@connections.delete(self)
    end
  
  end
end