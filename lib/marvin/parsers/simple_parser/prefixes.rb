# A Set of prefixes for a given IRC line
# as parsed from an incoming line.
class Marvin::Parsers::SimpleParser < Marvin::AbstractParser
  
  class Prefix; end
  
  class ServerNamePrefix < Prefix
    attr_accessor :server_name
    
    def initialize(name)
      self.server_name = name
    end
    
    def to_hash
      {:server => self.server_name}
    end
    
  end
  
  class UserPrefix < Prefix
    attr_accessor :nick, :ident, :host
    
    def initialize(nick, ident = nil, host = nil)
      self.nick = nick
      self.ident = ident
      self.host = host
    end
    
    def to_hash
      {:host => self.host, :nick => self.nick, :ident => self.ident}
    end
  end
  
end