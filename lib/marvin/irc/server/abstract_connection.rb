module Marvin::IRC::Server
  class AbstractConnection
    include Marvin::Dispatchable
    
    cattr_accessor :connections, :logger, :alive
    self.connections = []
    self.logger = Marvin::Logger
    
    attr_accessor :connection
    
    # Create a new connection with a given parent
    # and an incoming buffer of messages
    def initialize(parent, buffer = [])
      @connection = parent
      buffer.each { |line| receive_line(line) }
    end
  
    def receive_line(line)
      dispatch :incoming_line, :line => line
      event = Marvin::Settings.default_parser.parse(line)
      dispatch(event.to_incoming_event_name, event.to_hash) unless event.nil?
    end
    
    def send_line(line)
      @connection.send_line(line)
    end
    
    def process_connect
      @alive = true
      # Send the welcome notice / auth command.
      command :NOTICE, "AUTH", ":Marvin v#{Marvin.version} initialized, welcome."
      dispatch :client_connected, :client => self
    end
    
    def process_disconnect
      @@connections.delete(self)
      @alive = false
      dispatch :client_disconnected, :client => self
    end
    
    class << self
      
      # Return an array of all registered handlers, stored in the
      # class variable @@handlers. Used inside the #handlers instance
      # method as well as inside things such as register_handler.
      def handlers
        (@@handlers ||= {})[self] ||= []
      end
      
      # Assigns a new array of handlers and assigns each.
      def handlers=(new_value)
        (@@handlers ||= {})[self] = []
        new_value.to_a.each { |h| register_handler h }
      end
      
    end
    
    def dispatch(name, opts = {})
      opts[:connection] ||= self
      super
    end
    
    private
    
    def command(name, *args)
      opts = args.extract_options!
      formatted = [name.to_s.upcase, *args].join(" ")
      formatted = ":#{opts[:prefix]} #{formatted}" if opts[:prefix]
      send_line formatted
    end
    
    def peer_name
      return @peer_name unless @peer_name.blank?
      sock_addr = @connection.get_peername
      begin
        @peer_name = Socket.getnameinfo(sock_addr, Socket::NI_NAMEREQD).first
      rescue
        @peer_name = Socket.getnameinfo(sock_addr).first
      end
      return @peer_name
    end
  
  end
end