class Marvin::Parsers::SimpleParser < Marvin::AbstractParser
  module DefaultEvents
    
    def self.included(parent)
      parent.class_eval do
        extend ClassMethods
        # Register the default set of events with commands
        register_event :nick,    :NICK,    :new_nick
        register_event :quit,    :QUIT,    :message
        register_event :ping,    :PING,    :data
        register_event :join,    :JOIN,    :target
        register_event :invite,  :INVITE,  :target,  :channel
        register_event :message, :PRIVMSG, :target,  :message
        register_event :part,    :PART,    :target,  :message
        register_event :mode,    :MODE,    :target,  :mode               
        register_event :kick,    :KICK,    :target,  :channel, :reason
        register_event :topic,   :TOPIC,   :target,  :topic
        # Add the default numeric event
        register_event :numeric, :numeric, :code, :data
        # And a few others reserved for special purposed
        register_event :action,  :action,  :message
        register_event :ctcp,    :ctcp,    :message
      end
    end
    
    module ClassMethods
      
      # Register an event from a given name,
      # command as well as a set of arguments.
      def register_event(name, command, *args)
        event = Marvin::Parsers::SimpleParser::EventWithPrefix.new(name, *args)
        self.events[command] = event
      end
      
    end
  end
end