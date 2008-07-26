require 'eventmachine'
module Marvin::IRC
  
  
  # == Marvin::IRC::Client - An event machine backed IRC client
  #   
  #   Marvin::IRC::Client (MIC from here on in) is a simple IRC client
  #   built to implement the minimal amount of features required to run
  #   an IRC bot.
  #   
  #   MIC works by using a handler. Essentially, can set the current
  #   handler using:
  #   
  #     Marvin::IRC::Client::handler = MyHandler.new
  #   
  #   Typically, this handler will have at least one base method defined -
  #   handle - which accepts two parameters (a sym with the handle type and
  #   a hash with a key -> value set of information for it.By default, this
  #   defaults to the Singleton instance of Marvin::Base. 
  #   
  #   Other methods (of the form handle_[type] e.g. handle_message or handle_part)
  #   can be defined - these taking precedence over the the handle method. If said
  #   methods don't exist and neither does the handler instance, it will currently
  #   do nothing.
  
  module Client
    
    HANDLE_TYPES = {
      /^:(\S+) 433 \* (\w+) :(.+)$/ => [:nick_taken, [:server, :current, :message]],
      /^\:(.+)\!\~?(.+)\@(.+) PRIVMSG (\#\w+) \:(.+)$/ => [:message, [:nick, :ident, :host, :target, :message]],
      /^\:(.+)\!\~?(.+)\@(.+) PRIVMSG #{Marvin::Settings.nick} \:(.+)$/ => [:private_message, [:nick, :ident, :host, :target, :message]],
      /^\:(.+)\!\~?(.+)\@(.+) PING (.*)$/ => [:ping, [:nick, :ident, :host, :data]],
      /^\:(.+)\!\~?(.+)\@(.+) QUIT (\w+) \:(.+)$/ => [:quit, [:nick, :ident, :host, :user, :message]],
      /^\:(.+)\!\~?(.+)\@(.+) PART (\#?\w+) \:(.+)$/ => [:part, [:nick, :ident, :host, :user, :reason]],
    }
    
    ## EventMachine callbacks
    
    def post_init
      @lines  = []
      @buffer = ""
      @in_channels = []
      Marvin::Base.instance.client = self # set the client
      command! :user, Marvin::Settings.user, "0", "*", ":" + Marvin::Settings.name.to_s
      nick Marvin::Settings.nick
      join Marvin::Settings.channel
    end
    
    def receive_data(data)
      @buffer << data
      process_data
    end
    
    def unbind
    end
    
    ## Processing Code
    
    def process_data
      buffer_lines = @buffer.split("\r\n")
      if buffer_lines.length > 0 # Nonempty Buffy
        @buffer = (@buffer[-2..-1] == "\r\n") ? "" : buffer_lines.pop
        # For each line, process it unless it is empty / blank.
        buffer_lines.each { |line| process_line(line) unless line.blank? }
      end
    end
    
    def process_line(line)
      stored_match = nil
      match = HANDLE_TYPES.detect { |re, vals| (stored_match = re.match(line)) }
      if match
        properties = match[1]
        name       = properties[0]
        values     = stored_match.to_a[1..-1]
        options    = Hash[*properties[1].zip(values).flatten]
        if Marvin::Base.instance.respond_to?("handle_#{name}")
          Marvin::Base.instance.send("handle_#{name}", options)
        end
      else
       puts "Unrecognized: #{line}"
      end
    end
    
    def handler=(new_handler)
      if new_handler.respond_to?(:client=)
        # Automatically set the handler.
        new_handler.client = self
      end
      @handler = new_handler
    end
    
    def handler
      @handler ||= Marvin::Base.instance
    end
    
    def handle_callback(name, opts)
      current_handler = handler
      handler_name = name.to_s.underscore.to_sym
      
      if self.respond_to?("handle_#{handler_name}")
        # We're running a handler here ourselves,
        # hence we want to call that as well.
        self.send("handle_#{handler_name}", opts)
      end
      
      if handler.respond_to?("handle_#{handler_name}")
        handler.send("handle_#{handler_name}", opts)
      elsif handler.respond_to?(:handle)
        handler.handle(handler_name, opts)
      else
        Marvin::Logger.warn "No logger specified for #{handler_name} - Data was #{opts.inspect}"
      end
    end
    
    ## Default Integrated Handlers
    
    def handle_ping(opts = {})
      pong opts[:data]
    end
    
    ## Server Interactions
    
    def nick(new_nick)
      Marvin::Logger.debug "Setting Nick to #{new_nick}"
      command! :nick, new_nick
    end
    
    def join(channel)
      # Append the # symbol to the front of the name
      channel = "##{channel}" unless channel[0..0] == "#"
      Marvin::Logger.debug "Joining Channel #{channel}"
      command! :join, channel
    end
    
    def part(channel, message = nil)
      Marvin::Logger.debug "Parting #{channel} w/ message = #{message || 'Not Specified'}"
      command! :part, channel, message
    end
    
    def pong(data)
      command! :pong, data.strip
    end
    
    def say(message, target)
      command! :privmsg, target, message
    end
    
    ## Starting the client
    
    # Connects to the IRC server defined by Marvin::Settings.server and Marvin::Sending.port
    # and enters the event loop - using the rest of the client to process it. This is called
    # once all other components of the setup have been taken care of e.g. it usually doesn't
    # return.
    def self.run
      EventMachine::run do
        Marvin::Logger.debug "Connecting to #{Marvin::Settings.server}:#{Marvin::Settings.port} & entering event loop"
        EventMachine::connect Marvin::Settings.server, Marvin::Settings.port, self
      end
    end
    
    private
    
    def command!(keyword, *args)
      args.flatten!
      args.compact!
      args[-1] = ":#{args.last}" if args.length > 0 && args.last.include?(" ") && args.last[0..0] != ":"
      irc_command = "#{keyword.to_s.upcase} #{args.join(" ").strip} \r\n"
      Marvin::Logger.debug "Sending: #{irc_command}"
      send_data irc_command
    end
    
  end
end