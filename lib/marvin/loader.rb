module Marvin
  class Loader
    
    cattr_accessor :start_hooks, :stop_hooks, :setup_block, :type
    self.stop_hooks, self.start_hooks = [], []
    
    self.type = :client
    
    def self.before_connecting(&blk)
      self.setup_block = blk
    end
    
    def setup_defaults
      Marvin::Logger.setup
    end
    
    def self.before_run(&blk)
      self.start_hooks << blk unless blk.blank?
    end
    
    def self.after_stop(&blk)
      self.stop_hooks << blk unless blk.blank?
    end
    
    def load_handlers
      handlers = Dir[Marvin::Settings.root / "handlers/**/*.rb"].map { |h| h[0..-4] }
      handlers.each do |handler|
        require handler
      end
    end
    
    def load_settings
      Marvin::Settings.setup
      case Marvin::Loader.type
      when :client
        Marvin::Settings.default_client.configuration = Marvin::Settings.to_hash
        Marvin::Settings.default_client.setup
      when :server
      when :console
      end
    end
    
    def pre_connect_setup
      Marvin::DataStore.load!
      require(Marvin::Settings.root / "config/setup")
      self.setup_block.call unless self.setup_block.blank?
    end
    
    def run!
      Marvin::Options.parse! unless self.type == :console
      self.setup_defaults
      self.load_settings
      self.load_handlers
      self.pre_connect_setup
      self.start_hooks.each { |h| h.call }
      case self.type
      when :client
        Marvin::Settings.default_client.run
      when :server
        Marvin::IRC::Server.run
      when :ring_server
        Marvin::Distributed::RingServer.run
      when :distributed_client
        #Marvin::Distributed::Client.run
      end
    end
    
    def stop!
      Marvin::Settings.default_client.stop if self.type == :client
      self.stop_hooks.each { |h| h.call }
      Marvin::DataStore.dump!
    end
    
    def self.run!(type = :client)
      self.type = type.to_sym
      self.new.run!
    end
    
    def self.stop!
      self.new.stop!
    end
    
  end
end