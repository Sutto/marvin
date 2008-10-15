module Marvin
  class Loader
    
    cattr_accessor :setup_block
    
    cattr_accessor :start_hooks, :stop_hooks
    self.stop_hooks, self.start_hooks = [], []
    
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
      Marvin::Settings.default_client.configuration = Marvin::Settings.to_hash
      Marvin::Settings.default_client.setup
    end
    
    def pre_connect_setup
      Marvin::DataStore.load!
      require(Marvin::Settings.root / "config/setup")
      self.setup_block.call unless self.setup_block.blank?
    end
    
    def run!
      self.setup_defaults
      self.load_settings
      self.load_handlers
      self.pre_connect_setup
      self.start_hooks.each { |h| h.call }
      Marvin::Settings.default_client.run
    end
    
    def stop!
      Marvin::Settings.default_client.stop
      self.stop_hooks.each { |h| h.call }
      Marvin::DataStore.dump!
    end
    
    def self.run!
      self.new.run!
    end
    
    def self.stop!
      self.new.stop!
    end
    
  end
end