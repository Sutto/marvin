module Marvin::IRC
  class Event
    attr_accesor :regexp, :keys, :name, :match_data
    
    def initalize(name, regexp, *args)
      self.name = name.to_sym
      self.regexp = regexp
      self.keys = args.flatten.map { |k| k.to_sym }
    end
    
    def matches?(line)
      self.match_data = regexp.match(line)
    end
    
    def to_hash
      return {} unless self.match_data
      results = {}
      values = self.match_data.to_a[1..-1]
      self.keys.each do |key|
        results[key] = values.shift
      end
      return results
    end
    
    def to_incoming_event_name
      :"incoming_#{self.name}"
    end
    
  end
end