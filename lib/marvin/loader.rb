module Marvin
  class Loader
    
    cattr_accessor :setup_block
    
    def self.before_connecting(&blk)
      self.setup_block = blk
    end
    
    def setup_defaults
      Marvin::Logger.setup
    end
    
    def load_handlers
      handlers = Dir[File.present_dir / "../../handlers/**/*.rb"].map { |h| h[0..-4] }
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
      require(File.present_dir / "../../config/setup")
      self.setup_block.call unless self.setup_block.blank?
    end
    
    def run!
      self.setup_defaults
      self.load_settings
      self.load_handlers
      self.pre_connect_setup
      Marvin::Settings.default_client.run
    end
    
    def stop!
      Marvin::Settings.default_client.stop
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