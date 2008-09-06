require 'json'

module Marvin
  # Implements a simple datastore interface, designed to make
  # it easy to develop handlers which have persistent data.
  class DataStore
    
    cattr_accessor :logger, :registered_stores
    self.logger = Marvin::Logger.logger || ::Logger.new(STDOUT)
    self.registered_stores = {}
    
    def self.datastore_location
      path =  Marvin::Settings[:datastore_location] ? Marvin::Settings.datastore_location : "tmp/datastore.json"
      return File.dirname(__FILE__) / "../.." / path
    end
    
    def self.dump!
      File.open(self.datastore_location, "w+") do |f|
        f.write self.registered_stores.to_json
      end
    end
    
    def self.load!
      results = {}
      if File.exists?(self.datastore_location)
        begin
          json = JSON.load(File.read(self.datastore_location))
          results = json if json.is_a?(Hash)
        rescue JSON::ParserError
        end
      end
      self.registered_stores = results
    end
    
    
    # For each individual datastore.
    
    attr_accessor :name
    
    def initialize(name)
      self.name = name.to_s
      self.registered_stores ||= {}
      self.registered_stores[self.name] ||= {}
    end
    
    def [](key)
      self.registered_stores[self.name][key.to_s]
    end
    
    def []=(key,value)
      self.registered_stores[self.name][key.to_s] = value
    end
    
    def method_missing(name, *args, &blk)
      if name.to_s =~ /^(.*)=$/i
        self[$1.to_s] = args.first
      elsif self.registered_stores[self.name].has_key?(name.to_s)
        return self.registered_stores[self.name][name.to_s]
      else
        super(name, *args, &blk)
      end
    end
    
    def to_hash
      self.registered_stores[self.name]
    end
    
  end
end