require 'ostruct'
require 'eventmachine'
require 'active_support'
require File.dirname(__FILE__) + "/event"

module Marvin::IRC
  
  # == Marvin::IRC::Client
  # An EventMachine protocol implementation built to
  # serve as a basic, single server IRC client.
  #
  # Operates on the principal of Events as well
  # as handlers.
  #
  # === Events
  # Events are things that can happen (e.g. an
  # incoming message). All outgoing events are
  # automatically handled from within the client
  # class. Incoming events are currently based
  # on regular expression based matches of
  # incoming messages. the Client#register_event
  # method takes either an instance of Marvin::IRC::Event
  # or a set of arguments which will then be used
  # in the constructor of a new Marvin::IRC::Event
  # instance (see, for example, the source code for
  # this class for examples).
  #
  # === Handlers
  # Handlers on the other hand do as the name suggests
  # - they listen for dispatched events and act accordingly.
  # Handlers are simply objects which follow a certain
  # set of guidelines. Typically, a handler will at
  # minimum respond to #handle(event_name, details)
  # where event_name is a symbol for the current
  # event (e.g. :incoming_event) whilst details is a
  # a hash of details about the current event (e.g.
  # message target and the message itself).
  #
  # ==== Getting the current client instance
  # If the object responds to client=, The client will
  # call it with the current instance of itself
  # enabling the handler to do things such as respond.
  # Also, if a method handle_[message_name] exists,
  # it will be called instead of handle.
  #
  # ==== Adding handlers
  # To add an object as a handler, you simply call
  # the class method, register_handler with the
  # handler as the only argument.
  class Client < EventMachine::Protocols::LineAndTextProtocol
    
    cattr_accessor :events, :handlers, :configuration, :logger, :is_setup, :connections
    attr_accessor  :channels, :nickname
    
    # Set the default values for the variables
    self.handlers                 = []
    self.events                   = []
    self.configuration            = OpenStruct.new
    self.configuration.channels   = []
    self.connections              = []
    
    # Initializes the instance variables used for the
    # current connection, dispatching a :post_init event
    # once it has finished. During this process, it will
    # call #client= on each handler if they respond to it.
    def post_init
      super
      self.class.setup
      logger.debug "Initializing the current instance"
      self.channels = []
      (self.connections ||= []) << self
      logger.debug "Setting the client for each handler"
      self.handlers.each { |h| h.client = self if h.respond_to?(:client=) }
      logger.debug "Dispatching the default :client_connected event"
      dispatch_event :client_connected
    end
    
    def unbind
      self.connections.delete(self) if self.connections.include?(self)
      dispatch_event :client_disconnected
    end
    
    # Sets the current class-wide settings of this IRC Client
    # to either an OpenStruct or the results of #to_hash on
    # any other value that is passed in.
    def self.configuration=(config)
      @@configuration = config.is_a?(OpenStruct) ? config : OpenStruct.new(config.to_hash)
    end
    
    # Initializes class-wide settings and those that
    # are required such as the logger. by default, it
    # will convert the channel option of the configuration
    # to be channels - hence normalising it into a format
    # that is more widely used throughout the client.
    def self.setup
      return if self.is_setup
      # Default the logger back to a new one.
      self.configuration.channels ||= []
      unless self.configuration.channel.blank? || self.configuration.channels.include?(self.configuration.channel)
        self.configuration.channels.unshift(self.configuration.channel)
      end
      if configuration.logger.blank?
        require 'logger'
        configuration.logger = Marvin::Logger.logger
      end
      self.logger = self.configuration.logger
      self.is_setup = true
    end
    
    ## Handling all of the the actual client stuff.
    
    # Appends an event to the end of the the events callback
    # chain. It will be search in order of first-registered
    # when used to match a URL (hence, order matters).
    def self.register_event(*args)
      event = (args.first.is_a?(Marvin::IRC::Event) ? args.first : Marvin::IRC::Event.new(*args))
      self.events  << event
    end
    
    # Appends a handler to the end of the handler callback
    # chain. Note that they will be called in the order they
    # are appended.
    def self.register_handler(handler)
      return if handler.blank?
      self.handlers << handler
    end
    
    def receive_line(line)
      dispatch_event :incoming_line, :line => line
      event = self.events.detect { |e| e.matches?(line) }
      dispatch_event(event.to_incoming_event_name, event.to_hash) unless event.nil?
    end
    
    # Handles the dispatch of an event and it's associated options
    # / properties (defaulting to an empty hash) to both the client
    # (used for things such as responding to PING) and each of the
    # registered handlers.
    def dispatch_event(name, opts = {})
      # The full handler name is simply what is used to handle
      # a single event (e.g. handle_incoming_message)
      full_handler_name = "handle_#{name}"
      
      # If the current handle_name method is defined on this
      # class, we dispatch to that first. We use this to provide
      # functionality such as responding to PING's and handling
      # required stuff on connections.
      self.send(full_handler_name, opts) if respond_to?(full_handler_name)
      
      begin
        # For each of the handlers, check first if they respond to
        # the full handler name (e.g. handle_incoming_message) - calling
        # that if it exists - otherwise falling back to the handle method.
        # if that doesn't exist, nothing is done.
        self.handlers.each do |handler|
          if handler.respond_to?(full_handler_name)
            handler.send(full_handler_name, opts)
          elsif handler.respond_to?(:handle)
            handler.handle name, opts
          end
        end
      # Raise an exception in order to stop the flow
      # of the control. Ths enables handlers to prevent
      # responses from happening multiple times.
      rescue HaltHandlerProcessing
        logger.debug "Handler Progress halted; Continuing on."
      end
    end
    
    # Default handlers
    
    # The default handler for all things initialization-related
    # on the client. Usually, this will send the user command,
    # set out nick, join all of the channels / rooms we wish
    # to be in and if a password is specified in the configuration,
    # it will also attempt to identify us.
    def handle_client_connected(opts = {})
      logger.debug "About to handle post init"
      # IRC Connection is establish so we send all the required commands to the server.
      logger.debug "sending user command"
      command :user, self.configuration.user, "0", "*", lp(self.configuration.name)
      default_nickname = self.configuration.nick || self.configuration.nicknames.shift
      logger.debug "Setting default nickname"
      nick default_nickname
      # If a password is specified, we will attempt to message
      # NickServ to identify ourselves.
      say ":IDENTIFY #{self.configuration.password}", "NickServ" unless self.configuration.password.blank?
      # Join the default channels
      self.configuration.channels.each { |c| self.join c }
    end
   
    # The default handler for when a users nickname is taken on
    # on the server. It will attempt to get the nicknickname from
    # the nicknames part of the configuration (if available) and
    # will then call #nick to change the nickname.
    def handle_incoming_nick_taken(opts = {})
      logger.info "Nick Is Taken"
      logger.debug "Available Nicknames: #{self.configuration.nicknames.to_a.join(", ")}"
      available_nicknames = self.configuration.nicknames.to_a 
      if available_nicknames.length > 0
        logger.debug "Getting next nickname to switch"
        next_nick = available_nicknames.shift # Get the next nickname
        self.configuration.nicknames = available_nicknames
        logger.info "Attemping to set nickname to #{new_nick}"
        nick next_nick
      else
        logger.info "No Nicknames available - QUITTING"
        quit
      end
    end
    
    # The default response for PING's - it simply replies
    # with a PONG.
    def handle_incoming_ping(opts = {})
      logger.info "Recevied Incoming Ping - Handling with a PONG"
      pong(opts[:data])
    end
    
    ## General IRC Tools / Options
    
    # Starts the EventMachine loop and hence starts up the actual
    # networking portion of the IRC Client.
    def self.run
      self.setup # So we have options etc
      EventMachine::run do
        logger.debug "Connecting to #{self.configuration.server}:#{self.configuration.port}"
        EventMachine::connect self.configuration.server, self.configuration.port, self
      end
    end
    
    def self.stop
      logger.debug "Telling all connections to quit"
      self.connections.dup.each { |connection| connection.quit }
      logger.debug "Telling Event Machine to Stop"
      EventMachine::stop_event_loop
      logger.debug "Stopped."
    end
    
    ## General IRC Functions
    
    # Sends a specified command to the server.
    # Takes name (e.g. :privmsg) and all of the args.
    # Very simply formats them as a string correctly
    # and calls send_data with the results.
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
      self.channels << channel
      command :JOIN, channel
      logger.info "Joined channel #{channel}"
      dispatch_event :outgoing_join, :target => channel
    end
    
    def part(channel, reason = nil)
      channel = chan(channel)
      if self.channels.include?(channel)
        command :part, channel, lp(reason)
        dispatch_event :outgoing_part, :target => channel, :reason => reason
        logger.info "Parted from room #{channel}#{reason ? " - #{reason}" : ""}"
      else
        logger.warn "Tried to disconnect from #{channel} - which you aren't a part of"
      end
    end
    
    def quit(reason = nil)
      logger.debug self.channels.inspect
      self.channels.each { |chan| self.part chan, reason }
      command :quit
      dispatch_event :quit
      # Remove the connections from the pool
      self.connections.delete(self)
      logger.info  "Quit from server"
    end
    
    def msg(target, message)
      command :privmsg, target, lp(message)
      logger.info "Message sent to #{target} - #{message}"
      dispatch_event :outgoing_message, :target => target, :message => message
    end
    
    def action(target, message)
      action_text = lp "\01ACTION #{message.strip}\01"
      command :privmsg, target, action_text
      dispatch_event :outgoing_action, :target => target, :message => message
      logger.info "Action sent to #{target} - #{message}"
    end
    
    def pong(data)
      command :pong, data
      dispatch_event :outgoing_pong
      logger.info "PONG sent to #{data}"
    end
    
    def nick(new_nick)
      logger.info "Changing nickname to #{new_nick}"
      command :nick, new_nick
      self.nickname = new_nick
      dispatch_event :outgoing_nick, :new_nick => new_nick
      logger.info "Nickname changed to #{new_nick}"
    end
    
    # Some helper functions for clients
    
    # Registers a callback handle that will be periodically run.
    def periodically(timing, event_callback)
      callback = proc { self.dispatch_event event_callback.to_sym }
      EventMachine::add_periodic_timer(timing, &callback)
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
                   
    register_event :nick_taken, /^:(\S+) 433 \* (\w+) :(.+)$/,
                   :server, :target, :message
                   
    register_event :ping, /^\:(.+)\!\~?(.+)\@(.+) PING (.*)$/,
                   :nick, :ident, :host, :data

    private
    
    # Return the channel-name version of a string by
    # appending "#" to the front if it doesn't already
    # start with it.
    def chan(name)
      return name.to_s[0..0] == "#" ? name.to_s : "##{name}"
    end
    
    # Specifies the last parameter of a response, used to
    # specify parameters which have spaces etc (for example,
    # the actual message part of a response).
    def lp(section)
      section && ":#{section.to_s.strip} "
    end
    
  end
  
end