module Marvin
  module Parsers
    # A single incoming / outgoing irc command,
    # with handy utilities to convert it to a 
    # Marvin::IRC::Event instance.
    class Command
      
      @@commands = {}
      
      attr_accessor :raw, :prefix, :code, :params
      
      # Create a new command from the given raw
      # message.
      def initialize(raw)
        self.raw = raw
        self.params = []
      end
      
      # From the given command and arguments / params,
      # attempt to recognize the command and convert
      # it to an event which can be used for other stuff.
      def to_event
        if self.code =~ /^\d+$/
          ev = @@commands[:numeric].dup
          data = @params[0..-2]
          data << "#{@params.last.include?(" ") ? ":" : ""}#{@params.last}"
          ev.raw_arguments = [self.code.to_s, data.join(" ")]
        elsif code == "PRIVMSG" && params.last[0] == 1 && params.last[-1] == 1
          if params.last[0..8] == "\001ACTION: "
            name, value = :action, params.last[9..-2]
          else
            name, value = :ctcp, params.last[1..-2]
          end
          self.params[-1] = value
          ev = @@commands[name].dup
          ev.raw_arguments = self.params
        else
          ev = @@commands[self.code.to_sym]
          return nil if ev.nil?
          ev = ev.dup
          ev.raw_arguments = self.params
        end
        ev.prefix = self.prefix
        return ev
      end
      
      private
      
      # Adds an event that can be processed
      def self.register_event(name, command, *args)
        @@commands[command.to_sym] = Marvin::IRC::Event.new(name, *args)
      end
      
      register_event :pass,     :PASS,     :password
      register_event :user,     :USER,     :user, :mode, :unused, :real_name
      register_event :oper,     :OPER,     :name, :password
      register_event :service,  :SERVICE,  :nick, :reserved, :distribution, :type, :reserved, :info
      register_event :squit,    :SQUIT,    :server, :comment
      register_event :nick,     :NICK,     :new_nick
      register_event :quit,     :QUIT,     :message
      register_event :ping,     :PING,     :data, :server
      register_event :pong,     :PONG,     :data, :server
      register_event :join,     :JOIN,     :target, :key
      register_event :invite,   :INVITE,   :target, :channel
      register_event :message,  :PRIVMSG,  :target, :message
      register_event :part,     :PART,     :target, :message
      register_event :mode,     :MODE,     :target, :mode, :mode_params
      register_event :kick,     :KICK,     :target, :channel, :reason
      register_event :notice,   :NOTICE,   :target, :message
      register_event :topic,    :TOPIC,    :target, :topic
      register_event :names,    :NAMES,    :channel, :target
      register_event :list,     :LIST,     :channel, :target
      register_event :motd,     :MOTD,     :target
      register_event :lusers,   :LUSERS,   :mask, :target
      register_event :version,  :VERSION,  :target
      register_event :links,    :LINKS,    :remote, :mask
      register_event :connect,  :CONNECT,  :target, :port, :remote
      register_event :trace,    :TRACE,    :target
      register_event :admin,    :ADMIN,    :target
      register_event :info,     :INFO,     :target
      register_event :servlist, :SERVLIST, :mask, :type
      register_event :squery,   :SQUERY,   :service_name, :text
      register_event :who,      :WHO,      :mask, :o
      register_event :whois,    :WHOIS,    :target, :mask
      register_event :whowas,   :WHOWAS,   :nick, :count, :target
      register_event :kill,     :KILL,     :nick, :reason
      register_event :error,    :ERROR,    :message
      register_event :away,     :AWAY,     :reason
      register_event :rehash,   :REHASH
      register_event :die,      :DIE
      register_event :restart,  :RESTART
      register_event :summon,   :SUMMON,   :user, :target, :channel
      register_event :users,    :USERS,    :target
      register_event :wallops,  :WALLOPS,  :message
      register_event :userhost, :USERHOST, :nick
      register_event :ison,     :ISON,     :nick
      # Add the default numeric event
      register_event :numeric, :numeric, :code, :data
      # And a few others reserved for special purposed
      register_event :action,  :action,  :message
      register_event :ctcp,    :ctcp,    :message
      
    end
  end
end