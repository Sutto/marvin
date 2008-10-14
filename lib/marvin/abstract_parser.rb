module Marvin
  # An abstract class for an IRC protocol
  # Parser. Used as a basis for expirimentation.
  class AbstractParser
    
    def self.parse(line)
      return self.new(line.strip).to_event
    end
    
    def initialize(line)
      raise NotImplementedError, "Not implemented in an abstract parser"
    end
    
    def to_event
      raise NotImplementedError, "Not implemented in an abstract parser"
    end
    
  end
end