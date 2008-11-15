require 'ostruct'
require 'active_support'
require "marvin/irc/event"

module Marvin
  class AbstractClient
    
    include Marvin::Dispatchable
    
    cattr_accessor :events, :configuration, :logger, :is_setup, :connections
    attr_accessor  :channels, :nickname
    
    # Set the default values for the variables
    self.events                 = []
    self.configuration          = OpenStruct.new
    self.configuration.channels = []
    self.connections            = []
    
    # Initializes the instance variables used for the
    # current connection, dispatching a :client_connected event
    # once it has finished. During this process, it will
    # call #client= on each handler if they respond to it.
    def process_connect
      self.class.setup
      logger.debug "Initializing the current instance"
      self.channels = []
      self.connections << self
      logger.debug "Setting the client for each handler"
      self.handlers.each { |h| h.client = self if h.respond_to?(:client=) }
      logger.debug "Dispatching the default :client_connected event"
      dispatch :client_connected
    end
    
    def process_disconnect
      self.connections.delete(self) if self.connections.include?(self)
      dispatch :client_disconnected
      Marvin::Loader.stop! if self.connections.blank?
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
      logger.debug "About to handle post init"
      # IRC Connection is establish so we send all the required commands to the server.
      logger.debug "Setting default nickname"
      default_nickname = self.configuration.nick || self.configuration.nicknames.shift
      nick default_nickname
      logger.debug "sending user command"
      command :user, self.configuration.user, "0", "*", Marvin::Util.last_param(self.configuration.name)
      # If a password is specified, we will attempt to message
      # NickServ to identify ourselves.
      say ":IDENTIFY #{self.configuration.password}", "NickServ" unless self.configuration.password.blank?
      # Join the default channels
      self.configuration.channels.each { |c| self.join c }
    rescue Exception => e
      Marvin::ExceptionTracker.log(e)
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
      logger.info "Received Incoming Ping - Handling with a PONG"
      pong(opts[:data])
    end
    
    # TODO: Get the correct mapping for a given
    # Code.
    def handle_incoming_numeric(opts = {})
      code = opts[:code].to_i
      args = Marvin::Util.arguments(opts[:data])
      dispatch :incoming_numeric_processed, {:code => code, :data => args}
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
      send_line irc_command
    end
    
    def join(channel)
      channel = Marvin::Util.channel_name(channel)
      # Record the fact we're entering the room.
      self.channels << channel
      command :JOIN, channel
      logger.info "Joined channel #{channel}"
      dispatch :outgoing_join, :target => channel
    end
    
    def part(channel, reason = nil)
      channel = Marvin::Util.channel_name(channel)
      if self.channels.include?(channel)
        command :part, channel, Marvin::Util.last_param(reason)
        dispatch :outgoing_part, :target => channel, :reason => reason
        logger.info "Parted from room #{channel}#{reason ? " - #{reason}" : ""}"
      else
        logger.warn "Tried to disconnect from #{channel} - which you aren't a part of"
      end
    end
    
    def quit(reason = nil)
      logger.debug "Preparing to part from #{self.channels.size} channels"
      self.channels.to_a.each do |chan|
        logger.debug "Parting from #{chan}"
        self.part chan, reason
      end
      logger.debug "Parted from all channels, quitting"
      command :quit
      dispatch :quit
      # Remove the connections from the pool
      self.connections.delete(self)
      logger.info  "Quit from server"
    end
    
    def msg(target, message)
      command :privmsg, target, Marvin::Util.last_param(message)
      logger.info "Message sent to #{target} - #{message}"
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
      self.nickname = new_nick
      dispatch :outgoing_nick, :new_nick => new_nick
      logger.info "Nickname changed to #{new_nick}"
    end
    
  end
end