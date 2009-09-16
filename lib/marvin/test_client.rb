module Marvin
  # Marvin::TestClient is a simple client used for testing
  # Marvin::Base derivatives in a non-network-reliant setting.
  class TestClient < AbstractClient
    
    attr_accessor :incoming_commands, :outgoing_commands, :last_sent,
                  :dispatched_events, :connection_open
    
    cattr_accessor :instances
    @@instances = []
    
    DispatchedEvents = Struct.new(:name, :options)
    
    def initialize(opts = {})
      super
      @incoming_commands = []
      @outgoing_commands = []
      @dispatched_events = []
      @connection_open   = false
      @@instances << self
    end
    
    def connection_open?
      !!@connection_open
    end
    
    def send_line(*args)
      @outgoing_commands += args
      @last_sent = args.last
    end
    
    def test_command(name, *args)
      options   = args.extract_options!
      host_mask = options.delete(:host_mask) || ":WiZ!jto@tolsun.oulu.fi"
      name      = name.to_s.upcase
      args      = args.flatten.compact
      receive_line "#{host_mask} #{name} #{args.join(" ").strip}"
    end
    
    def dispatch(name, opts = {})
      @dispatched_events << [name, opts]
      super(name, opts)
    end
    
    def self.run
      @@instances.each { |i| i.connection_open = true }
    end
    
    def self.stop
      @@instances.each { |i| i.connection_open = false }
    end
    
    def self.add_reconnect(opts = {})
      logger.info "Added reconnect with options: #{opts.inspect}"
    end
    
  end
end