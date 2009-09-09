module Marvin
  # An abstract class for an IRC protocol
  # Parser. Used as a basis for expirimentation.
  class AbstractParser
    
    def self.parse(line)
      self.new(line.strip).to_event
    end
    
    attr_accessor :line, :command, :event
    
    # Instantiates a parser instance, attempts to 
    # parse it for it's command and it's event.
    def initialize(line)
      @line    = line
      @command = self.class.parse!(line)
      @event   = @command.to_event unless @command.blank?
    end
    
    def to_event
      @event
    end
    
    private
    
    def self.parse!(line)
      raise NotImplementedError, "Must be implemented in a subclass"
    end
    
  end
end