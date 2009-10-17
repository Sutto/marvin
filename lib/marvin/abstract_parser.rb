module Marvin
  # Abstract Class for implementing abstract parsers.
  class AbstractParser
    
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
    
    # Parses a line and return the associated event.
    # @return [Marvin::IRC:Event] the parsed event
    def self.parse(line)
      new(line.strip).to_event
    end
    
    protected
    
    def self.parse!(line)
      raise NotImplementedError, "Must be implemented in a subclass"
    end
    
  end
end