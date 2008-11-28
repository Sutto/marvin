require 'ostruct'
require 'active_support'

module Marvin
  # Marvin::TestClient is a simple client used for testing
  # Marvin::Base derivatives in a non-network-reliant setting.
  class TestClient < AbstractClient
    attr_accessor :incoming_commands, :outgoing_commands, :last_sent, :dispatched_events, :connection_open
    
    cattr_accessor :instances
    self.instances = []
    
    DispatchedEvents = Struct.new(:name, :options)
    
    def initialize(opts = {})
      super
      self.incoming_commands = []
      self.outgoing_commands = []
      self.dispatched_events = []
      self.connection_open   = false
      self.instances << self
    end
    
    def connection_open?
      self.connection_open
    end
    
    def send_line(*args)
      self.outgoing_commands += args
      self.last_sent = args.last
    end
    
    def test_command(name, *args)
      options = args.extract_options!
      host_mask = options.delete(:host_mask) || ":WiZ!jto@tolsun.oulu.fi"
      name = name.to_s.upcase
      args = args.flatten.compact
      irc_command = "#{host_mask} #{name} #{args.join(" ").strip}"
      self.receive_line irc_command
    end
    
    def dispatch(name, opts = {})
      self.dispatched_events << [name, opts]
      super(name, opts)
    end
    
    def self.run
      self.instances.each do |i|
        i.connection_open = true
      end
    end
    
    def self.stop
      self.instances.each do |i|
        i.connection_open = false
      end
    end
    
    def self.add_reconnect(opts = {})
      Marvin::Logger.info "Added reconnect with options: #{opts.inspect}"
    end
    
  end
end