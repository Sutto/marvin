module Marvin
  # An abstract class for an IRC protocol
  # Parser. Used as a basis for expirimentation.
  class AbstractParser
    
    def self.parse(line)
      return self.new(line.strip).to_event
    end
    
    attr_accessor :line, :command, :event
    
    # Instantiates a parser instance, attempts to 
    # parse it for it's command and it's event.
    def initialize(line)
      self.line = line
      self.command = self.class.parse!(line)
      self.event = self.command.to_event unless self.command.blank?
    end
    
    def to_event
      self.event
    end
    
    private
    
    def self.parse!(line)
      raise NotImplementedError, "Must be implemented in a subclass"
    end
    
  end
end