module Marvin::IRC
  class Event
    attr_accessor :keys, :name, :raw_arguments, :prefix
    
    def initialize(name, *args)
      self.name = name.to_sym
      self.keys = args.flatten.map { |k| k.to_sym }
    end
    
    def to_hash
      return @hash_value unless @hash_value.blank?
      results = {}
      values = self.raw_arguments.to_a
      last_index = self.keys.size - 1
      self.keys.each_with_index do |key, i|
        results[key] = (i == last_index ? values.join(" ").strip : values.shift)
      end
      results.merge!(prefix.to_hash) unless prefix.blank?
      return (@hash_value = results)
    end
    
    def inspect
      "#<Marvin::IRC::Event name=#{self.name} attributes=#{self.to_hash.inspect} >"
    end
    
    def to_incoming_event_name
      :"incoming_#{self.name}"
    end
    
    def to_outgoing_event_name
      :"outgoing_#{self.name}"
    end
    
  end
end