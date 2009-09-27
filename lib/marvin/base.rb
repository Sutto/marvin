require 'set'

module Marvin
  
  def self.handler_parent_classes
    @@handler_parent_classes ||= Hash.new { |h,k| h[k] = Set.new }
  end
  
  class Base
    is :loggable
    
    @@handlers = Hash.new do |h,k|
      h[k] = Hash.new { |h2, k2| h2[k2] = [] }
    end
    
    attr_accessor :client, :target, :from, :options
    
    class << self
        
      def registered?
        @registered ||= false
      end
      
      def registered=(value)
        @registered = !!value
      end
      
      # Returns an array of all handlers associated with
      # a specific event name (e.g. :incoming_message)
      def event_handlers_for(message_name)
        message_name = message_name.to_sym
        items = []
        klass = self
        while klass != Object
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
        @@handlers[self][name] << blk
      end
      
      # Like on_event but instead of taking an event name it takes
      # either a number or a name - corresponding to an IRC numeric
      # reply.
      def on_numeric(value, method_name = nil, &blk)
        value = value.is_a?(Numeric) ? ("%03d" % value) : Marvin::IRC::Replies[value]
        on_event(:"incoming_numeric_#{new_value}", method_name, &blk) if value.present?
      end
      
      # Register this specific handler on the IRC handler.
      def register!(parent = Marvin::Settings.client)
        return if self == Marvin::Base # Only do it for sub-classes.
        parent.register_handler self.new unless parent.handlers.any? { |h| h.class == self }
        Marvin.handler_parent_classes[self.name] << parent
      end
    
      def reloading!
        Marvin.handler_parent_classes[self.name].each do |dispatcher|
          parent_handlers = dispatcher.handlers
          related = parent_handlers.select { |h| h.class == self }
          related.each do |h|
            h.handle(:reloading, {})
            dispatcher.delete_handler(h)
          end
        end
      end
      
      def reloaded!
        Marvin.handler_parent_classes[self.name].each do |dispatcher|
          before = dispatcher.handlers
          register!(dispatcher)
          after = dispatcher.handlers
          (after - before).each do |h|
            h.client = dispatcher
            h.handle(:reloaded, {})
          end
        end
      end
    
    end
    
    def handle(message, options)
      dup._handle(message, options)
    end
    
    # Given an incoming message, handle it appropriately by getting all
    # associated event handlers. It also logs any exceptions (aslong as
    # they raised by halt)
    def _handle(message, options)
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
    
    def action(message, target = self.target)
      client.action(target, message)
    end
    
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
      !from_channel?
    end
    
    # Determines whether a given target (defaulting to the target of the
    # last message was in a channel)
    def from_channel?(target = self.target)
      target.present? && target =~ /^[\&\#]/
    end
    
    def addressed?
      from_user? || options.message =~ /^#{client.nickname.downcase}:\s+/i
    end
    
    # A Perennial automagical helper for dispatch
    def registered=(value)
      self.class.registered = value
    end
    
    protected
    
    # Initializes details for the current cycle - in essence, this makes the
    # details of the current request available.
    def setup_details(options)
      @options = options.is_a?(Marvin::Nash) ? options : Marvin::Nash.new(options.to_hash)
      @target  = @options.target if @options.target?
      @from    = @options.nick   if @options.nick?
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