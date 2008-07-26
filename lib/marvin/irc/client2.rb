require 'ostruct'
require 'eventmachine'
require 'active_support'
require File.dirname(__FILE__) + "/event"

module Marvin::IRC
  
  # == Marvin::IRC::Client2
  # Try using a protocol vs. a module
  class Client2 < EventMachine::Protocols::LineAndTextProtocol
    
    cattr_accessor :events, :handlers, :configuration, :logger, :is_setup
    attr_accessor  :channels, :nickname
    
    # Initialize the class
    def post_init
      super
      self.channels = []
      self.handlers.each { |h| h.client = self if h.respond_to?(:client=) }
      handle_event :post_init
    end
    
    def self.configuration=(config)
      config_hash = config.to_hash
      super(OpenStruct.new(config_hash))
    end
    
    # Prepares it for usage.
    def self.setup
      return if self.is_setup
      # Default the logger back to a new one.
      if configuration.logger.blank?
        require 'logger'
        configuration.logger = ::Logger.new(STDERR)
      end
      self.is_setup = true
    end
    
    # Handling all of the the actual client stuff.
    
    def self.register_event(*args)
      event = (args.first.is_a?(Marvin::IRC::Event) ? args.first : Marvin::IRC::Event.new(*args))
      (self.events ||= []) << event
    end
    
    def self.register_handler(handler)
      return if handler.blank?
      (self.handlers ||= []) << handler
    end
    
    def receive_line(line)
      handle_event :incoming_line, :line => line
      event = self.events.detect { |e| e.matches?(line) }
      logger.debug(event ? "Logger matched event #{event.name}" : "Unknown response")
      handle_event(event.to_incoming_event_name, event.to_hash) unless event.nil?
    end
    
    def handle_event(name, opts = {})
      full_handler_name = "handle_#{name}"
      
      # If the current handle_name method is defined on this
      # class, we dispatch to that first.
      self.send(full_handler_name, opts) if respond_to?(full_handler_name)
      
      # Handle an event inside each of the handler classes.
      handlers.each do |handler|
        if handler.respond_to?(full_handler_name, opts)
          handler.send(full_handler_name)
        elsif handler.respond_to?(:handle)
          handler.handle name, opts
        else
          logger.debug "#{handler.inspect} doesn't have a handle for #{name} with options #{opts.inspect}"
        end
      end
    end
    
    # Default handlers
    
    def handle_post_init(opts = {})
      # IRC Connection is establish so join the room and set the nick.
      command :user, self.configuration.user, "0", "*", lp(self.configuration.name)
      default_nickname = self.configuration.nick || self.configuration.nicknames.shift
      nick default_nickname
      say ":IDENTIFY #{self.configuration.password}", "NickServ" unless self.configuration.password.blank?
      # Join the default channels
      self.configuration.channels.each { |c| self.join c }
      # Finally, 
    end
    
    def handle_incoming_nick_taken(opts = {})
      logger.info "Nick Is Taken"
      if self.configuration.nicknames.is_a?(Array) && !self.configuration.nicknames.empty?
        next_nick = self.configuration.next_nick.shift
        nick next_nick
      else
        logger.warn "No Nicknames available - QUITTING"
        quit
      end
    end
    
    def handle_incoming_ping(opts = {})
      logger.info "Recevied Incoming Ping - Handling"
      pong(opts[:data])
    end
    
    # General IRC Tools / Options
    
    def self.run
      self.setup # So we have options etc
      EventMachine::run do
        logger.debug "Connecting"
        EventMachine::connect self.configuration.server, (self.configuration.port || 6667), self
      end
    end
    
    # General IRC Functions
    
    def command(name, *args)
      # First, get the appropriate command
      name = name.to_s.upcase
      args = args.flatten.compact
      irc_command = "#{name} #{args.join(" ").strip} \r\n"
      send_data irc_command
    end
    
    def join(channel)
      channel = chan(channel)
      # Record the fact we're entering the room.
      self.channels << channels
      command :JOIN, channel
      logger.info "Joined channel #{channel}"
      handle_event :outgoing_join, :target => channel
    end
    
    def part(channel, reason = nil)
      channel = chan(channel)
      if self.channels.include?(channel)
        command :part, channel, lp(reason)
        handle_event :outgoing_part, :target => channel, :reason => reason
        logger.info "Parted from room #{channel}#{reason ? " - #{reason}" : ""}"
      else
        logger.warn "Tried to disconnect from #{channel} - which you aren't a part of"
      end
    end
    
    def quit(channel, reason = nil)
      self.channels.each { |chan| self.part chan, reason }
      command :quit
      handle_event :quit
      logger.info  "Quit from server"
    end
    
    def msg(target, message)
      command :privmsg, target, lp(message)
      logger.info "Message sent to #{target} - #{message}"
      handle_event :outgoing_message, :target => target, :message => message
    end
    
    def action(target, message)
      action_text = lp "\01ACTION #{message.strip}\01"
      command :privmsg, target, action_text
      handle_event :outgoing_action, :target => target, :message => message
      logger.info "Action sent to #{target} - #{message}"
    end
    
    def pong(data)
      command :pong, data
      handle_event :outgoing_pong
      logger.info "PONG sent to #{data}"
    end
    
    def nick(new_nick)
      command :nick, new_nick
      self.nickname = new_nick
      handle_event :outgoing_nick, :new_nick => new_nick
      logger.info "Nickname changed to #{new_nick}"
    end
    
    # Some helper functions for clients
    
    # Registers a callback handle that will be periodically run.
    def periodically(timing, event_callback)
      callback = proc { self.handle_event event_callback.to_sym }
      EventMachine::add_periodic_timer(timing, &callback)
    end
    
    # Declare the default outgoing events
    
    # Please note, these regexp's are thanks to Net::YAIL - apparantly also
    # coming from IRCSocket.
    
    register_event :invite,  /^\:(.+)\!\~?(.+)\@(.+) INVITE (\S+) :?(.+?)$/i,
                   :nick, :ident, :host, :target, :channel
                   
    register_event :action,  /^\:(.+)\!\~?(.+)\@(.+) PRIVMSG (\S+) :?\001ACTION (.+?)\001$/i,
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
                   
    register_event :nick_taken, /^:(\S+) 433 \* (\w+) :(.+)$/,
                   :server, :target, :message
                   
    register_event :ping, /^\:(.+)\!\~?(.+)\@(.+) PING (.*)$/,
                   :nick, :ident, :host, :data


    private
    
    def chan(name)
      return name.to_s[0..0] == "#" ? name.to_s : "##{name}"
    end
    
    # Specifies the last param - which is quoted etc.
    def lp(section)
      section && ":#{section.to_s.strip} "
    end
    
  end
end