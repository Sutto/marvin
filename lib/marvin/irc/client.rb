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
      /^\:(.+)\!\~?(.+)\@(.+) PART (\#?\w+) \:?(.*)$/ => [:part, [:nick, :ident, :host, :channel, :reason]],
      /^\:(.+)\!\~?(.+)\@(.+) JOIN \:?(\#\w+).*$/ => [:join, [:nick, :ident, :host, :room]]
    }
    
    ## EventMachine callbacks
    
    def post_init
      @lines  = []
      @buffer = ""
      @in_channels = []
      Marvin::Base.instance.client = self # set the client
      command! :user, Marvin::Settings.user, "0", "*", ":" + Marvin::Settings.name # name is a special case
      nick Marvin::Settings.nick
      join Marvin::Settings.channel
      say  ":IDENTIFY #{Marvin::Settings.password}", "NickServ" if Marvin::Settings[:password]
    end
    
    def receive_data(data)
      @buffer << data
      process_data
      # post_receive is a handle that let's you do
      # things such as add tasks that run every X
      # but not that it's dependant on receiving
      # data of some sort every so often.
      handle_callback :post_receive
    end
    
    def unbind
    end
    
    ## Processing Code
    
    # Get's any complete lines from the buffer and then proceeds
    # to call process_line on each
    def process_data
      buffer_lines = @buffer.split("\r\n")
      if buffer_lines.length > 0 # Nonempty Buffy
        @buffer = (@buffer[-2..-1] == "\r\n") ? "" : buffer_lines.pop
        # For each line, process it unless it is empty / blank.
        buffer_lines.each { |line| process_line(line) unless line.blank? }
      end
    end
    
    # Given an individual line, finds a matching HANDLE_TYPES value
    # and then uses the results to built the data to be passed to
    # If no match is found, it simply prints to stdout and proceeds
    # on it's merry way.
    def process_line(line)
      stored_match = nil
      match = HANDLE_TYPES.detect { |re, vals| (stored_match = re.match(line)) }
      if match
        properties = match[1] # The properties array
        name       = properties[0]
        options    = Hash[*properties[1].zip(stored_match.to_a[1..-1]).flatten]
        handle_callback(name, options)
      else
       puts "Unrecognized: #{line}"
      end
    end
    
    # Set the handler for this client to a specific
    # object. See the module overview for specific details
    def handler=(new_handler)
      if new_handler.respond_to?(:client=)
        # Automatically set the handler.
        new_handler.client = self
      end
      @handler = new_handler
    end
    
    # Get the current handler for this module.
    def handler
      @handler ||= Marvin::Base.instance
    end
    
    def channels
      @in_channels ||= []
    end
    
    # Take's a handle type (as name) and a hash of options
    # (extracted from data) and calls the respective handlers
    # on both the Client (self) and the designated handler.
    def handle_callback(name, opts = {})
      current_handler = handler
      handler_name = name.to_s.underscore.to_sym
      full_handler_name = "handle_#{handler_name}"
      
      if self.respond_to?(full_handler_name)
        # We're running a handler here ourselves,
        # hence we want to call that as well.
        # used for things like responding to PING
        self.send(full_handler_name, opts)
      end
      
      # Check if our handler is setup to respond
      # to this in some fashion.
      if handler.respond_to?(full_handler_name)
        handler.send(full_handler_name, opts)
      elsif handler.respond_to?(:handle)
        handler.handle(handler_name, opts)
      else
        Marvin::Logger.debug "No handler specified for #{handler_name} - Data was #{opts.inspect}"
      end
    end
    
    def periodically(time, target = nil, &blk)
      blk ||= proc { self::handle_callback(target, {}) }
      EventMachine::add_periodic_timer(time, &blk)
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
      self.channels << channel
      Marvin::Logger.debug "Joining Channel #{channel} - Now in #{self.channels * ", "}"
      command! :join, channel
    end
    
    def part(channel, message = nil)
      channel = "##{channel}" unless channel[0..0] == "#"
      Marvin::Logger.debug "Parting #{channel} w/ message = #{message || 'Not Specified'}"
      self.channels.delete(channel)
      command! :part, channel, message
    end
    
    def quit(message = nil)
      Marvin::Logger.debug "Asked to quit the server"
      self.channels.each { |channel| part channel, message }
      command! :quit
      EventMachine::stop
    end
    
    def pong(data)
      command! :pong, data.strip
    end
    
    def say(message, target)
      handle_callback :say, :message => message, :target => target, :nick => Marvin::Settings.nick
      command! :privmsg, target, message
    end
    
    def action(action, target)
      handle_callback :action, :message => action, :target => target, :nick => Marvin::Settings.nick
      command! :privmsg, target, ":\01ACTION #{action}\01"
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