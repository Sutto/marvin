require 'yaml'
require 'eventmachine'

module Marvin
  class Settings
    
    cattr_accessor :environment, :configuration, :is_setup, :default_client, :distributed_namespace,
                   :handler_folder, :default_parser, :log_level, :verbose, :daemon
                   
    self.verbose   = false
    self.log_level = :info
    self.daemon    = false
    
    class << self
      
      def daemon?
        self.daemon
      end
      
      def root
        File.expand_path(defined?(MARVIN_ROOT) ? MARVIN_ROOT : File.dirname(__FILE__) / "../..")
      end
      
      def setup(options = {})
        return if self.is_setup
        self.setup!(options)
      end
      
      def distributed_namespace
        @@distributed_namespace ||= :default
      end
      
      def setup!(options = {})
        self.environment ||= "development"
        self.configuration = {}
        self.default_client ||= Marvin::IRC::Client
        self.default_parser ||= Marvin::Parsers::SimpleParser
        loaded_yaml = YAML.load_file(root / "config/settings.yml")
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