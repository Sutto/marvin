module Marvin
  # The middle man is a class you can use to register
  # other handlers on. e.g. it acts as a way to 'filter'
  # incoming and outgoing messages. Akin to Rack / WSGI
  # middleware.
  class MiddleMan
    
    # Set the logger cattr to the default marvin logger.
    cattr_accessor :logger
    self.logger ||= Marvin::Logger
    
    # By default, we are *not* setup.
    @@setup = false
    
    # Our list of subhandlers. We make sure
    # the list is unique to our subclass / class.
    class_inheritable_accessor :subhandlers
    self.subhandlers = []
    
    # Finally, the client.
    attr_reader :client
  
    # When we're told to set the client,
    # not only do we set out own instance
    # but we also echo the command down
    # to all of our sub-clients.
    def client=(new_client)
      @client = new_client
      setup_subhandler_clients
    end
    
    def handle(message, options)
      begin
        full_handler_name = "handle_#{message}"
        self.send(full_handler_name, opts) if respond_to?(full_handler_name)
        self.subhandlers.each do |sh|
          forward_message_to_handler(sh, message, options, full_handler_name)
        end
      rescue HaltHandlerProcessing
        logger.info "Asked to halt the filter processing chain inside a middleman."
      rescue Exception => e
        logger.fatal "Exception processing handle #{message}"
        logger.fatal "#{e} - #{e.message}"
        e.backtrace.each do |line|
          logger.fatal line
        end
      end
    end
    
    class << self
      
      def setup?
        @@setup
      end
      
      # Forcefully do the setup routine.
      def setup!
        # Register ourselves as a new handler.
        Marvin::Settings.default_client.register_handler self.new
        @@setup = true
      end
      
      # Setup iff setup hasn't been done.
      def setup
        return if self.setup?
        self.setup!
      end
      
      # Register a single subhandler.
      def register_handler(handler, run_setup = true)
        self.setup if run_setup
        self.subhandlers << handler unless handler.blank?
      end
      
      # Registers a group of subhandlers.
      def register_handlers(*args)
        self.setup
        args.each { |h| self.register_handler(h, false) }
      end
      
    end
    
    private
    
    def setup_subhandler_clients
      self.subhandlers.each do |sh|
        sh.client = self.client if sh.respond_to?(:client=)
      end
    end
    
    # This should probably be extracted into some sort of Util's library as
    # it's shared across a couple of classes but I really can't be bothered
    # at the moment - I just want to test the concept.
    def forward_message_to_handler(handler, message, options, full_handler_name)
      if handler.respond_to?(full_handler_name)
        handler.send(full_handler_name, options)
      elsif handler.respond_to?(:handle)
        handler.handle message, options
      end
    end
    
  end
end