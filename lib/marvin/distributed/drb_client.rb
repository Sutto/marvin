module Marvin
  module Distributed
    # A method for operating on marvin objects.
    class DRbClient
      
      # Wait 1 second on a lookup.
      LOOKUP_TIMEOUT = 1
      
      class << self
        
        @@handlers = []
        attr_accessor :stopped
        
        def register_handler(handler)
          @@handlers << handler unless handler.nil? || !handler.respond_to?(:handle)
        end
        
        def dispatch(name, opts, client)
          Marvin::Logger.debug "Processing Event: #{name}"
          full_handler_name = :"handle_#{name.to_s.underscore}"
          @@handlers.each do |handler|
            has_client = handler.respond_to?(:client=)
            handler.client = client if has_client
            if handler.respond_to?(full_handler_name)
              handler.send(full_handler_name, opts)
            else
              handler.handle name, opts
            end
            handler.client = nil if has_client
          end
        rescue HaltHandlerProcessing => e
          Marvin::Logger.info "Halting processing chain"
        rescue Exception => e
          Marvin::ExceptionTracker.log(e)
        end
        
        # Starts up a drb processor / client, and walks through the process of dealing
        # with it / processing events.
        def run
          self.stopped = false
          Marvin::Logger.info "Starting up DRb Client"
          DRb.start_service
          # Loop through, making sure we have a valid
          # RingFinger and then process events as they
          # appear.
          enter_loop!
        end
        
        def stop
          self.stopped = true
        end
        
        def ring_server
          @ring_server = Rinda::RingFinger.finger.lookup_ring(LOOKUP_TIMEOUT) if @ring_server.nil?
          return @ring_server
        rescue RingNotFound
          @ring_server = nil
        end
        
        def enter_loop!
          Marvin::Logger.info "Entering processing loop"
          while !self.stopped
            begin
              unless self.ring_server.blank?
                event = self.ring_server.take([:marvin_event, Marvin::Settings.distributed_namespace, nil, nil, nil], 2)
                dispatch(*event[2..-1]) unless event.blank?
              end
            rescue
              # Reset the ring server on event of connection refused etc.
              @ring_server = nil
            end
          end
        end
        
      end
    end
  end
end