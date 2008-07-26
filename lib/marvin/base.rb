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
      logger.debug "Saying: #{message} to #{target}"
      client.msg message, target
    end
    
    def pm(target, message)
      say(message, target)
    end
    
    def reply(message)
      if from_channel?
        say "#{self.from}: #{message}"
      else
        say message, self.from # Default back to pm'ing the user
      end
    end
    
    def from_user?
      self.target && !from_channel?
    end
    
    def from_channel?
      self.target && self.target[0..0] == "#"
    end
    
    def get_handlers_for(message)
      self.registered_handlers[message] ||= []
    end
    
    def setup_defaults(options)
      self.options = options
      self.target  = options[:target] if options.has_key?(:target)
      self.from    = options[:nick]   if options.has_key?(:nick)
    end
    
  end
end