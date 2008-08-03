require 'ostruct'

module Marvin
  # A Client Handler
  class Base
    
    cattr_accessor :logger
    # Set the default logger
    self.logger ||= Marvin::Logger
    
    attr_accessor :client, :target, :from, :options, :logger
    class_inheritable_accessor :registered_handlers
    
    def initialize
      self.registered_handlers ||= {}
      self.logger ||= Marvin::Logger
    end
    
    class << self
      
      def on_event(name, &blk)
        logger
        self.registered_handlers ||= {}
        self.registered_handlers[name] ||= []
        self.registered_handlers[name] << blk
      end
      
      # Register's in the IRC Client callback chain.
      def register!
        return if self == Marvin::Base # Only do it for sub-classes.
        Marvin::IRC::Client2.register_handler self.new
      end
      
    end
    
    # Given an incoming message, handle it appropriatly.
    def handle(message, options)
      begin
        self.setup_defaults(options)
        get_handlers_for(message).each do |handle|
          self.instance_eval &handle
        end
      rescue Exception => e
        logger.fatal "Exception processing handle #{message}"
        logger.fatal "#{e} - #{e.message}"
        e.backtrace.each do |line|
          logger.fatal line
        end
      end
    end
    
    def say(message, target = self.target)
      client.msg target, message
    end
    
    def pm(target, message)
      say(target, message)
    end
    
    def reply(message)
      if from_channel?
        say "#{self.from}: #{message}"
      else
        say message, self.from # Default back to pm'ing the user
      end
    end
    
    def ctcp(message)
      return if from_channel? # Must be from user
      say "\01#{message}\1", self.from
    end
    
    # Request information
    
    # reflects whether or not the current message / previous message came
    # from a user via pm.
    def from_user?
      self.target && !from_channel?
    end
    
    # Determines whether the previous message was inside a channel.
    def from_channel?
      self.target && self.target[0..0] == "#"
    end
    
    def addressed?
      self.from_user? || options.message.split(" ").first == "#{self.client.nickname}:"
    end
    
    # Get's the registered handler for a certain type of message.
    def get_handlers_for(message)
      self.registered_handlers[message] ||= []
    end
    
    def setup_defaults(options)
      self.options = options.is_a?(OpenStruct) ? options : OpenStruct.new(options)
      self.target  = options[:target] if options.has_key?(:target)
      self.from    = options[:nick]   if options.has_key?(:nick)
    end
    
    # Halt's on the handler, used to prevent
    # other handlers also responding to the same
    # message more than once.
    def halt!
      raise HaltHandlerProcessing
    end
    
  end
end