module Marvin
  module Parsers
    module Prefixes
      # Generic server name prefix
      class Server
        
        attr_accessor :name
        
        def initialize(name = nil)
          self.name = name || ""
        end
        
        def to_hash
          {:server => @name.freeze}
        end
        
        def to_s
          @name.to_s
        end
        
      end
    end
  end
end