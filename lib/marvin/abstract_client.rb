require 'ostruct'
require 'active_support'
require "marvin/irc/event"

module Marvin
  class AbstractClient
    
    include Marvin::Dispatchable
    
    def initialize(opts = {})
      self.original_opts    = opts.dup # Copy the options so we can use them to reconnect.
      self.server           = opts[:server]
      self.port             = opts[:port]
      self.default_channels = opts[:channels]
      self.nicks            = opts[:nicks] || []
      self.pass             = opts[:pass]
    end
    
    cattr_accessor :events, :configuration, :logger, :is_setup, :connections
    attr_accessor  :channels, :nickname, :server, :port, :nicks, :pass, :disconnect_expected, :original_opts
    
    # Set the default values for the variables
    @@events                 = []
    @@configuration          = OpenStruct.new
    @@configuration.channels = []
    @@connections            = []
    
    # Initializes the instance variables used for the
    # current connection, dispatching a :client_connected event
    # once it has finished. During this process, it will
    # call #client= on each handler if they respond to it.
    def process_connect
      self.class.setup
      logger.info "Initializing the current instance"
      @channels = []
      connections << self
      logger.info "Setting the client for each handler"
      handlers.each { |h| h.client = self if h.respond_to?(:client=) }
      logger.info "Dispatching the default :client_connected event"
      dispatch :client_connected
    end
    
    def process_disconnect
      logger.info "Handling disconnect for #{self.server}:#{self.port}"
      connections.delete(self) if connections.include?(self)
      dispatch :client_disconnected
      unless @disconnect_expected
        logger.warn "Lost connection to server - adding reconnect"
        self.class.add_reconnect self.original_opts
      else
        Marvin::Loader.stop! if self.connections.blank?
      end
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
      if configuration.logger.blank?
        require 'logger'
        configuration.logger = Marvin::Logger.logger
      end
      self.logger = self.configuration.logger
      self.is_setup = true
    end
    
    ## Handling all of the the actual client stuff.
    
    def receive_line(line)
      dispatch :incoming_line, :line => line
      event = Marvin::Settings.default_parser.parse(line)
      dispatch(event.to_incoming_event_name, event.to_hash) unless event.nil?
    end
    
    # Default handlers
    
    # The default handler for all things initialization-related
    # on the client. Usually, this will send the user command,
    # set out nick, join all of the channels / rooms we wish
    # to be in and if a password is specified in the configuration,
    # it will also attempt to identify us.
    def handle_client_connected(opts = {})
      logger.info "About to handle client connected"
      # If the pass is set
      unless self.pass.blank?
        logger.info "Sending pass for connection"
        command :pass, self.pass
      end
      # IRC Connection is establish so we send all the required commands to the server.
      logger.info "Setting default nickname"
      default_nickname = self.nicks.shift
      nick default_nickname
      logger.info "sending user command"
      command :user, self.configuration.user, "0", "*", Marvin::Util.last_param(self.configuration.name)
    rescue Exception => e
      Marvin::ExceptionTracker.log(e)
    end
    
    def default_channels
      @default_channels ||= []
    end
    
    def default_channels=(channels)
      @default_channels = channels.to_a.map { |c| c.to_s }
    end
    
    def host_with_port
      @host_with_port ||= "#{self.server}:#{self.port}"
    end
    
    def nicks
      if @nicks.blank? && !@nicks_loaded
        logger.info "Setting default nick list"
        @nicks = []
        @nicks << configuration.nick
        @nicks += configuration.nicks.to_a unless configuration.nicks.blank?
        @nicks.compact!
        @nicks_loaded = true
      end
      return @nicks
    end
    
    # The default response for PING's - it simply replies
    # with a PONG.
    def handle_incoming_ping(opts = {})
      logger.info "Received Incoming Ping - Handling with a PONG"
      pong(opts[:data])
    end
    
    # TODO: Get the correct mapping for a given
    # Code.
    def handle_incoming_numeric(opts = {})
      case opts[:code]
        when Marvin::IRC::Replies[:RPL_WELCOME]
          handle_welcome
        when Marvin::IRC::Replies[:ERR_NICKNAMEINUSE]
          handle_nick_taken
        when Marvin::IRC::Replies[:RPL_TOPIC]
          handle_channel_topic
      end
      code = opts[:code].to_i
      args = Marvin::Util.arguments(opts[:data])
      dispatch :incoming_numeric_processed, :code => code, :data => args
    end
    
    def handle_welcome
      logger.info "Welcome received from server"
      # If a password is specified, we will attempt to message
      # NickServ to identify ourselves.
      say ":IDENTIFY #{self.configuration.password}", "NickServ" unless configuration.password.blank?
      # Join the default channels IF they're already set
      # Note that Marvin::IRC::Client.connect will set them AFTER this stuff is run.
      default_channels.each { |c| join(c) }
    end
    
    # The default handler for when a users nickname is taken on
    # on the server. It will attempt to get the nicknickname from
    # the nicknames part of the configuration (if available) and
    # will then call #nick to change the nickname.
    def handle_nick_taken
      logger.info "Nickname '#{nickname}' on #{server} taken, trying next." 
      logger.info "Available Nicknames: #{nicks.empty? ? "None" : nicks.join(", ")}"
      if !nicks.empty?
        logger.info "Getting next nickname to switch"
        next_nick = nicks.shift # Get the next nickname
        logger.info "Attemping to set nickname to '#{next_nick}'"
        nick next_nick
      else
        logger.fatal "No Nicknames available - QUITTING"
        quit
      end
    end
    
    def handle_channel_topic
      # TODO: Check if the channel is one we attempted to join.
      # If it is, we move it from the 'pending_channels' list to
      # the list of channels we are currently in.
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
      send_line "#{name} #{args.join(" ").strip}\r\n"
    end
    
    def join(channel)
      channel = Marvin::Util.channel_name(channel)
      # Record the fact we're entering the room.
      # TODO: Refactor to only add the channel when we receive confirmation we've joined.
      channels << channel
      command :JOIN, channel
      logger.info "Joined channel #{channel}"
      dispatch :outgoing_join, :target => channel
    end
    
    def part(channel, reason = nil)
      channel = Marvin::Util.channel_name(channel)
      if channels.include?(channel)
        command :part, channel, Marvin::Util.last_param(reason)
        dispatch :outgoing_part, :target => channel, :reason => reason
        logger.info "Parted from room #{channel}#{reason ? " - #{reason}" : ""}"
      else
        logger.warn "Tried to part from #{channel} when no JOIN was recorded."
      end
    end
    
    def quit(reason = nil)
      @disconnect_expected = true
      logger.info "Preparing to part from #{channels.size} channels"
      channels.to_a.each do |chan|
        logger.info "Parting from #{chan}"
        part chan, reason
      end
      logger.info "Parted from all channels, quitting"
      command  :quit
      dispatch :outgoing_quit
      # Remove the connections from the pool
      connections.delete(self)
      logger.info  "Quit from server"
    end
    
    def msg(target, message)
      command :privmsg, target, Marvin::Util.last_param(message)
      logger.info "Message sent to #{target}: #{message}"
      dispatch :outgoing_message, :target => target, :message => message
    end
    
    def action(target, message)
      action_text = Marvin::Util.last_param "\01ACTION #{message.strip}\01"
      command :privmsg, target, action_text
      dispatch :outgoing_action, :target => target, :message => message
      logger.info "Action sent to #{target} - #{message}"
    end
    
    def pong(data)
      command :pong, data
      dispatch :outgoing_pong
      logger.info "PONG sent to #{data}"
    end
    
    def nick(new_nick)
      logger.info "Changing nickname to #{new_nick}"
      command :nick, new_nick
      @nickname = new_nick
      dispatch :outgoing_nick, :new_nick => new_nick
      logger.info "Nickname changed to #{new_nick}"
    end
    
  end
end