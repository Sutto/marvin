require 'ostruct'
require 'active_support'

module Marvin
  # Marvin::TestClient is a simple client used for testing
  # Marvin::Base derivatives in a non-irc-reliant setting.
  class TestClient
    
    cattr_accessor :handlers, :logger, :is_setup
    attr_accessor  :channels, :nickname
    
    def initialize(opts = {})
      self.configuration = opts unless opts.keys.empty?
      self.channels = []
    end
    
    def command(name, args)
      logger.info "Sending IRC Command #{name} - #{args.inspect}"
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
      logger.info "Changing nickname to #{new_nick}"
      command :nick, new_nick
      self.nickname = new_nick
      handle_event :outgoing_nick, :new_nick => new_nick
      logger.info "Nickname changed to #{new_nick}"
    end

    private

    def chan(name)
      return name.to_s[0..0] == "#" ? name.to_s : "##{name}"
    end

    # Specifies the last param - which is quoted etc.
    def lp(section)
      section && ":#{section.to_s.strip} "
    end

    # Class Methods - mostly related to setup

    def self.configuration=(config)
        @@configuration = OpenStruct.new((config || {}).to_hash)
    end
    
    def self.configuration
        @@configuration ||= {}
    end
    
    def configuration=(settings)
      self.class.configuration = settings
    end
    
    def configuration
      self.class.configuration
    end

    # Prepares it for usage.
    def self.setup
      return if self.is_setup
      # Default the logger back to a new one.
      self.handlers               ||= []
      self.configuration          ||= {}
      self.configuration.channels ||= []
      unless self.configuration.channel.blank? || self.configuration.channels.include?(self.configuration.channel)
        self.configuration.channels.unshift(self.configuration.channel)
      end
      if configuration.logger.blank?
        require 'logger'
        configuration.logger = ::Logger.new(STDERR)
      end
      self.logger = self.configuration.logger
      self.is_setup = true
    end
  
    # Handling all of the the actual client stuff.  

    def self.register_handler(handler)
      return if handler.blank?
      (self.handlers ||= []) << handler
    end
    
  end
end