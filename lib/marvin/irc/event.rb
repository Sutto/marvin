module Marvin::IRC
  class Event
    attr_accessor :keys, :name, :raw_arguments, :prefix
    
    def initialize(name, *args)
      @name = name.to_sym
      @keys = args.flatten.map { |k| k.to_sym }
    end
    
    def to_hash
      return @hash_value unless @hash_value.blank?
      results = {}
      values = @raw_arguments.to_a
      last_index = @keys.size - 1
      @keys.each_with_index do |key, i|
        results[key] = (i == last_index ? values.join(" ").strip : values.shift)
      end
      results.merge!(@prefix.to_hash) unless @prefix.blank?
      @hash_value = results
    end
    
    def inspect
      "#<Marvin::IRC::Event name=#{@name} attributes=#{to_hash.inspect} >"
    end
    
    def to_event_name(prefix = nil)
      [prefix, @name].join("_").to_sym
    end
    
    def to_incoming_event_name
      to_event_name :incoming
    end
    
    def to_outgoing_event_name
      to_event_name :outgoing
    end
    
  end
end