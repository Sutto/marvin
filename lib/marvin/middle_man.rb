module Marvin
  class MiddleMan
    is :loggable, :dispatchable
    
    attr_reader :client
  
    class << self
      def setup?
        @@setup ||= false
      end

      def setup!
        Marvin::Settings.client.register_handler self.new
        @@setup = true
      end

      # Setup iff setup hasn't been done.
      def setup
        setup! unless setup?
      end
    end

    # When we're told to set the client, not only do we set out own instance
    # but we also echo the command down to all of our sub-clients.
    def client=(new_client)
      @client = new_client
      setup_subhandler_clients
    end
    
    def process_event(message, options)
      return message, options
    end
    
    # Filter incoming events.
    def handle(message, options)
      message, options = process_event(message, options)
      dispatch(message, options)
    end
    
    private
    
    def setup_subhandler_clients
      current_client = self.client
      handlers.each { |sh| sh.client = current_client if sh.respond_to?(:client=) }
    end
    
  end
end