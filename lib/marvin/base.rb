require 'ostruct'

module Marvin
  class Base
    is :loggable
    
    @@handlers = Hash.new do |h,k|
      h[k] = Hash.new { |h2, k2| h2[k2] = [] }
    end
    
    attr_accessor :client, :target, :from, :options, :logger
    
    class << self
      
      # Returns an array of all handlers associated with
      # a specific event name (e.g. :incoming_message)
      def event_handlers_for(message_name)
        message_name = message_name.to_sym
        items = []
        klass = self
        while klass != Class
          items += @@handlers[klass][message_name]
          klass = klass.superclass
        end
        items
      end
      
      # Registers a block to be used as an event handler. The first
      # argument is always the name of the event and the second
      # is either a method name (e.g. :my_awesome_method) or
      # a block (which is instance_evaled)
      def on_event(name, method_name = nil, &blk)
        blk = proc { self.send(method_name) } if method_name.present?
        @@handlers[self][method_name] << blk
      end
      
      # Like on_event but instead of taking an event name it takes
      # either a number or a name - corresponding to an IRC numeric
      # reply.
      def on_numeric(value, method_name = nil, &blk)
        value = value.is_a?(Numeric) ? ("%03d" % value) : Marvin::IRC::Replies[value]
        on_event(:"incoming_numeric_#{new_value}", method_name, &blk) if value.present?
      end
      
      # Register this specific handler on the IRC handler.
      def register!(parent = Marvin::Settings.default_client)
        return if self == Marvin::Base # Only do it for sub-classes.
        parent.register_handler self.new
      end
    
    end
    
    # Given an incoming message, handle it appropriately by getting all
    # associated event handlers. It also logs any exceptions (aslong as
    # they raised by halt)
    def handle(message, options)
      setup_details(options)
      h = self.class.event_handlers_for(message)
      h.each { |eh| self.instance_eval(&eh) }
    rescue Exception => e
      # Pass on halt_handler_processing events.
      raise e if e.is_a?(Marvin::HaltHandlerProcessing)
      logger.fatal "Exception processing handler for #{message.inspect}"
      Marvin::ExceptionTracker.log(e)
    ensure
      reset_details
    end
    
    # The default handler for numerics. mutates them into a more
    # friendly version of themselves. It will also pass through
    # the original incoming_numeric event.
    def handle_incoming_numeric(opts)
      handle(:incoming_numeric, opts)
      handle(:"incoming_numeric_#{opts[:code]}", opts)
    end
    
    # msg sends the given text to the current target, be it
    # either a channel or a specific user.
    def msg(message, target = self.target)
      client.msg(target, message)
    end
    
    alias say msg
    
    # A conditional version of message that will only send the message
    # if the target / from is a user. To do this, it uses from_channel?
    def pm(message, target)
      say(message, target) unless from_channel?(target)
    end
    
    # Replies to a message. if it was received in a channel, it will
    # use the standard irc "Name: text" convention for replying whilst
    # if it was in a direct message it sends it as is.
    def reply(message)
      if from_channel?
        say("#{from}: #{message}")
      else
        say(message, from)
      end
    end
    
    def ctcp(message)
      say("\01#{message}\01", from) if !from_channel?
    end
    
    # Request information
    
    # reflects whether or not the current message / previous message came
    # from a user via pm.
    def from_user?
      target && !from_channel?
    end
    
    # Determines whether a given target (defaulting to the target of the
    # last message was in a channel)
    def from_channel?(target = self.target)
      target && target =~ /^[\&\#]/
    end
    
    def addressed?
      from_user? || options.message =~ /^#{client.nickname.downcase}:\s+/i
    end
    
    protected
    
    # Initializes details for the current cycle - in essence, this makes the
    # details of the current request available.
    def setup_details(options)
      @options = options.is_a?(OpenStruct) ? options : OpenStruct.new(options)
      @target  = options[:target] if options.has_key?(:target)
      @from    = options[:nick] if options.has_key?(:nick)
    end
    
    def reset_details
      @options = nil
      @target = nil
      @from = nil
    end
    
    # Halt can be called during the handle / process. Doing so
    # prevents any more handlers in the handler chain from being
    # called. It's kind of like return but it works across all
    # handlers, not just the current one.
    def halt!
      raise Marvin::HaltHandlerProcessing
    end
    
  end
end