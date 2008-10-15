require File.dirname(__FILE__) / "simple_parser/prefixes"
require File.dirname(__FILE__) / "simple_parser/event_extensions"
require File.dirname(__FILE__) / "simple_parser/default_events"

module Marvin
  module Parsers
    class SimpleParser < Marvin::AbstractParser
      
      cattr_accessor :events
      self.events = {}
      
      attr_accessor :arguments, :prefix, :current_line, :parts, :event
      
      def initialize(line)
        self.current_line = line
        parse!
      end
      
      def to_event
        if self.event.blank?
          parse!
          return nil
        else
          return self.event
        end
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
        command = self.parts.shift.upcase.to_sym
        if command =~ /^[0-9]{3}$/
          # Other Command
          self.parts = [self.parts.join(" ")]
          process_event self.events[:numeric]
        elsif self.commands.has_key? command
          # Registered Command
          process_event self.events[command]
        else
          # Unknown Command
          self.event = nil
        end
      end
      
      def process_event(prototype, skip_mutation = false)
        self.event = prototype.dup
        self.event.prefix = self.prefix
        self.event.raw_arguments = self.parts
        mutate_event! unless skip_mutation
      end
      
      def mutate_event!
        # Do nothing by default
        name, contents = self.event.name, self.event.raw_arguments.last
        # mutate for ctcp and actions
        if name == :message && contents[0..0] == "\001" && contents[-1..-1] == "\001"
          if message.index("ACTION: ") == 1
            message = message[9..-2]
            new_event = :action
          else
            message = message[1..-2]
            new_event = :ctcp
          end
          self.parts = [message]
          process_event self.events[new_event], true
        end
      end
      
      def extract_prefix!(text)
        full_prefix = text[1..-1]
        prefix = full_prefix
        if full_prefix =~ /^([^@!]+)(!\~([^@]+))?(@(.*))?$/ # Ugly regexp for nick!ident@host format
          prefix = UserPrefix.new($1, $3, $5)
        else
          # TODO: Validate the hostname here.
          prefix = ServerNamePrefix.new(prefix.strip)
        end
        self.prefix = prefix
        return prefix
      end
      
      include Marvin::Parsers::SimpleParser::DefaultEvents
    
    end 
  end
end