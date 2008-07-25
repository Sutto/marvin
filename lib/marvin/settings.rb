require 'yaml'

module Marvin
  class Settings
    
    cattr_accessor :environment, :configuration, :is_setup
    
    class << self
      
      def setup(options = {})
        return if self.is_setup
        self.setup!(options)
      end
      
      def setup!(options = {})
        self.environment ||= "development"
        self.configuration = {}
        loaded_yaml = YAML.load_file(File.present_dir / "../../config/settings.yml")
        loaded_options = loaded_yaml["default"].
                           merge(loaded_yaml[self.environment]).
                           merge(options)
        self.configuration.merge!(loaded_options)
        self.configuration.symbolize_keys!
        self.is_setup = true
      end
      
      def [](key)
        self.setup
        return self.configuration[key.to_sym]
      end
      
      def []=(key, value)
        self.setup
        self.configuration[key.to_sym] = value
        return value
      end
      
      def to_hash
        self.configuration
      end
      
      def method_missing(name, *args, &blk)
        if self.configuration.has_key?(name.to_sym) && args.blank?
          return self.configuration[name.to_sym]
        else
          super(name, *args, &blk)
        end
      end
      
    end

  end
end