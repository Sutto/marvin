require 'ostruct'

module Marvin
  # A Client Handler
  class Base
    
    cattr_accessor :logger
    # Set the default logger
    self.logger ||= Marvin::Logger
    
    attr_accessor :client, :target, :from, :options, :logger
    class_inheritable_accessor :registered_handlers
    self.registered_handlers = {}
    
    def initialize
      self.registered_handlers ||= {}
      self.logger ||= Marvin::Logger
    end
    
    class << self
      
      def event_handlers_for(message_name, direct = true)
        return [] if self == Marvin::Base
        rh = (self.registered_handlers ||= {})
        rh[self.name] ||= {}
        rh[self.name][message_name] ||= []
        if direct
          found_handlers = rh[self.name][message_name]
          found_handlers += self.superclass.event_handlers_for(message_name)
          return found_handlers
        else
          return rh[self.name][message_name]
        end
      end
      
      # Registers a block or method to be called when
      # a given event is occured.
      # == Examples
      #
      #   on_event :incoming_message, :process_commands
      # 
      # Will call process_commands the current object
      # every time incoming message is called.
      #
      #   on_event :incoming_message do
      #     Marvin::Logger.debug ">> #{options.inspect}"
      #   end
      #
      # Will invoke the block every time an incoming message
      # is processed.
      def on_event(name, method_name = nil, &blk)
        # If the name is set and it responds to :to_sym
        # and no block was passed in.
        blk = proc { self.send(method_name.to_sym) } if method_name.respond_to?(:to_sym) && blk.blank?
        self.event_handlers_for(name, false) << blk
      end
      
      def on_numeric(value, method_name = nil, &blk)
        if value.is_a?(Numeric)
          new_value = "%03d" % value
        else
          new_value = Marvin::IRC::Replies[value]
        end
        if new_value.nil?
          logger.error "The numeric '#{value}' was undefined"
        else
          blk = proc { self.send(method_name.to_sym) } if method_name.respond_to?(:to_sym) && blk.blank?
          self.event_handlers_for(:"incoming_numeric_#{new_value}", false) << blk
        end
      end
      
      # Register's in the IRC Client callback chain.
      def register!(parent = Marvin::Settings.default_client)
        return if self == Marvin::Base # Only do it for sub-classes.
        parent.register_handler self.new
      end
      
      def uses_datastore(datastore_name, local_name)
        cattr_accessor local_name.to_sym
        self.send("#{local_name}=", Marvin::DataStore.new(datastore_name))
        rescue Exception => e
          logger.debug "Exception in datastore declaration - #{e.inspect}"
      end
      
    end
    
    # Given an incoming message, handle it appropriatly.
    def handle(message, options)
      begin
        self.setup_defaults(options)
        h = self.class.event_handlers_for(message)
        h.each { |handle| self.instance_eval(&handle) }
      rescue Exception => e
        logger.fatal "Exception processing handle #{message}"
        Marvin::ExceptionTracker.log(e)
      end
    end
    
    def handle_incoming_numeric(opts)
      self.handle(:incoming_numeric, opts)
      name = :"incoming_numeric_#{options.code}"
      events = self.class.event_handlers_for(name)
      logger.debug "Dispatching #{events.size} events for #{name}"
      events.each { |eh| self.instance_eval(&eh) }
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
      say "\01#{message}\01", self.from
    end
    
    # Request information
    
    # reflects whether or not the current message / previous message came
    # from a user via pm.
    def from_user?
      self.target && !from_channel?
    end
    
    # Determines whether the previous message was inside a channel.
    def from_channel?
      self.target && [?#, ?&].include?(self.target[0])
    end
    
    def addressed?
      self.from_user? || options.message =~ /^#{self.client.nickname.downcase}:\s+/i
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