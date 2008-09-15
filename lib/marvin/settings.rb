require 'yaml'

module Marvin
  class Settings
    
    cattr_accessor :environment, :configuration, :is_setup, :default_client
    
    class << self
      
      def setup(options = {})
        return if self.is_setup
        self.setup!(options)
      end
      
      def setup!(options = {})
        self.environment ||= "development"
        self.configuration = {}
        self.default_client ||= begin
                                  require 'eventmachine'
                                  Marvin::IRC::Client
                                rescue LoadError
                                  Marvin::IRC::SocketClient
                                end
        loaded_yaml = YAML.load_file(File.present_dir / "../../config/settings.yml")
        loaded_options = loaded_yaml["default"].
                           merge(loaded_yaml[self.environment]).
                           merge(options)
        self.configuration.merge!(loaded_options)
        self.configuration.symbolize_keys!
        mod = Module.new do
          Settings.configuration.keys.each do |k|
            define_method(k) do
              return Settings.configuration[k]
            end
          
            define_method("#{k}=") do |val|
              Settings.configuration[k] = val
            end
          end
        end
        
        # Extend and include.
        
        extend  mod
        include mod
        
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
      
    end

  end
end