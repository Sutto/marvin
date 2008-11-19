module Marvin
  # = Marvin::Dispatchable
  # A Generic mixin which lets you define an object
  # Which accepts handlers which can have arbitrary
  # events dispatched.
  # == Usage
  #
  #   class X
  #     include Marvin::Dispatchable
  #     self.handlers << SomeHandler.new
  #   end
  #   X.new.dispatch(:name, {:args => "Values"})
  #
  # Will first check if SomeHandler#handle_name exists,
  # calling handle_name({:args => "Values"}) if it does,
  # otherwise calling SomeHandler#handle(:name, {:args => "Values"})
  module Dispatchable
    
    def self.included(parent)
      parent.class_eval do
        include InstanceMethods
        extend  ClassMethods
      end
    end
    
    module InstanceMethods
      
      # Returns the handlers registered on this class,
      # used inside +dispatch+. Note that it will call
      # dup on each of the objects to get a new instance.
      # please ensure your object acts accordingly.
      def handlers
        @handlers ||= self.class.handlers.map { |h| h.dup }
      end
      
      # Dispatch an 'event' with a given name to the handlers
      # registered on the current class. Used as a nicer way of defining
      # behaviours that should occur under a given set of circumstances.
      # == Params
      # +name+: The name of the current event
      # +opts+: an optional hash of options to pass
      def dispatch(name, opts = {})
        # The full handler name is the method we call given it exists.
        full_handler_name = :"handle_#{name.to_s.underscore}"
        # First, dispatch locally if the method is defined.
        if self.respond_to?(full_handler_name)
          self.send(full_handler_name, opts)
        end
        # Iterate through all of the registered handlers,
        # If there is a method named handle_<event_name>
        # defined we sent that otherwise we call the handle
        # method on the handler. Note that the handle method
        # is the only required aspect of a handler. An improved
        # version of this would likely cache the respond_to?
        # call.
        self.handlers.each do |handler|
          if handler.respond_to?(full_handler_name)
            handler.send(full_handler_name, opts)
          else
            handler.handle name, opts
          end
        end
      # If we get the HaltHandlerProcessing exception, we
      # catch it and continue on our way. In essence, we
      # stop the dispatch of events to the next set of the
      # handlers.
      rescue HaltHandlerProcessing => e
        Marvin::Logger.info "Halting processing chain"
      rescue Exception => e
        Marvin::ExceptionTracker.log(e)
      end
      
    end
    
    module ClassMethods
      
      # Return an array of all registered handlers, stored in the
      # class variable @@handlers. Used inside the #handlers instance
      # method as well as inside things such as register_handler.
      def handlers
        @@handlers ||= []
      end
      
      # Assigns a new array of handlers and assigns each.
      def handlers=(new_value)
        @@handlers = []
        new_value.to_a.each { |h| register_handler h }
      end
      
      # Appends a handler to the list of handlers for this object.
      # Handlers are called in the order they are registered.
      def register_handler(handler)
        self.handlers << handler unless handler.nil? || !handler.respond_to?(:handle)
      end
      
    end
    
  end
end