module Marvin
  module Parsers
    class SimpleParser < Marvin::AbstractParser
      
      class Prefix; end
      
      class ServerNamePrefix < Prefix
        attr_accessor :server_name
        
        def initialize(name)
          self.server_name = name
        end
        
        def to_hash
          {:server_name => self.server_name}
        end
        
      end
      
      class UserPrefix < Prefix
        attr_accessor :nick, :user, :hostname
        
        def initialize(nick, user, hostname)
          self.nick = nick
          self.user = user
          self.hostname = hostname
        end
        
        def to_hash
          [:nick, :user, :hostname].inject({}) { |n, c| n[c] = self.send(c); n }
        end
      end
      
      cattr_accessor :events
      
      attr_accessor :arguments, :prefix, :current_line, :parts, :event
      
      def initialize(line)
        self.current_line = line
        parse!
      end
      
      def to_event
      end
      
      private
      
      def parse!
        # Split the message
        line = self.current_line
        if line[0] == ?:
          prefix_text, line = line.split(" ", 2)
        else
          prefix_text = nil
        end
        head, tail = line.split(":", 2)
        self.parts = head.split(" ")
        self.parts << tail
        command = self.parts.shift.to_sym
        if command =~ /^[0-9]{3}$/
          self.event = 
        else
          
        end
      end
      
      def extract_prefix!(text)
        full_prefix = text[1..-1]
        prefix = full_prefix
        return prefix
      end
      
    end 
  end
end