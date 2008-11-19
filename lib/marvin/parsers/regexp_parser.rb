module Marvin
  module Parsers
    class RegexpParser < Marvin::AbstractParser
    
      cattr_accessor :regexp_matchers, :events
      # Since we cbf implemented an ordered hash, just use regexp => event at the same
      # index.
      self.regexp_matchers = []
      self.events = []
    
      attr_accessor :current_line
    
      # Appends an event to the end of the the events callback
      # chain. It will be search in order of first-registered
      # when used to match a URL (hence, order matters).
      def self.register_event(*args)
        matcher = args.delete_at(1) # Extract regexp.
        if args.first.is_a?(Marvin::IRC::Event)
          event = args.first
        else
          event = Marvin::IRC::Event.new(*args)
        end
        self.regexp_matchers << matcher
        self.events << event
      end
    
    
      # Initialize a new RegexpParser from the given line.
      def initialize(line)
        self.current_line = line
      end
    
      def to_event
        self.regexp_matchers.each_with_index do |matcher, offset|
          if (match_data = matcher.match(self.current_line))
            event = self.events[offset].dup
            event.raw_arguments = match_data.to_a[1..-1]
            return event
          end
        end
        # otherwise, return nil
        return nil
      end
    
      ## The Default IRC Events
    
      # Note that some of these Regexp's are from Net::YAIL,
      # which apparantly sources them itself from the IRCSocket
      # library.
    
      register_event :invite,  /^\:(.+)\!\~?(.+)\@(.+) INVITE (\S+) :?(.+?)$/i,
                     :nick, :ident, :host, :target, :channel
                   
      register_event :action,  /^\:(.+)\!\~?(.+)\@(.+) PRIVMSG (\S+) :?\001ACTION (.+?)\001$/i,
                     :nick, :ident, :host, :target, :message
                   
      register_event :ctcp, /^\:(.+)\!\~?(.+)\@(.+) PRIVMSG (\S+) :?\001(.+?)\001$/i,
                     :nick, :ident, :host, :target, :message
    
      register_event :message, /^\:(.+)\!\~?(.+)\@(.+) PRIVMSG (\S+) :?(.+?)$/i,
                     :nick, :ident, :host, :target, :message
                   
      register_event :join,    /^\:(.+)\!\~?(.+)\@(.+) JOIN (\S+)/i,
                     :nick, :ident, :host, :target               
                   
      register_event :part,    /^\:(.+)\!\~?(.+)\@(.+) PART (\S+)\s?:?(.+?)$/i,
                     :nick, :ident, :host, :target, :message
                   
      register_event :mode,    /^\:(.+)\!\~?(.+)\@(.+) MODE (\S+) :?(.+?)$/i,
                     :nick, :ident, :host, :target, :mode               

      register_event :kick,    /^\:(.+)\!\~?(.+)\@(.+) KICK (\S+) (\S+)\s?:?(.+?)$/i,
                     :nick, :ident, :host, :target, :channel, :reason
                   
      register_event :topic,  /^\:(.+)\!\~?(.+)\@(.+) TOPIC (\S+) :?(.+?)$/i,
                     :nick, :ident, :host, :target, :topic
                   
      register_event :nick,    /^\:(.+)\!\~?(.+)\@(.+) NICK :?(.+?)$/i,
                     :nick, :ident, :host, :new_nick

      register_event :quit,    /^\:(.+)\!\~?(.+)\@(.+) QUIT :?(.+?)$/i,
                     :nick, :ident, :host, :message
                   
      register_event :ping,   /^\:(.+)\!\~?(.+)\@(.+) PING (.*)$/,
                     :nick, :ident, :host, :data
                     
      register_event :ping,  /PING (.*)$/, :data

      register_event :numeric, /^\:(\S+) ([0-9]+) (.*)$/,
                     :server, :code, :data
    end 
  end
end