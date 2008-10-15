# An extension to Marvin::IRC::Event which
# lets a user specify a prefix to use.
class Marvin::Parsers::SimpleParser < Marvin::AbstractParser
  
  class EventWithPrefix < Marvin::IRC::Event
    attr_accessor :prefix
    
    def to_hash
      super.merge(prefix.blank? ? {} : prefix.to_hash)
    end
    
  end
  
end