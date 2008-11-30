module Marvin
  module Distributed
    # A method for operating on marvin objects.
    class DRbClient
      class << self
        
        @@handlers = []
        
        def register_handler(handler)
          @@handlers << handler unless handler.nil? || !handler.respond_to?(:handle)
        end
        
        def dispatch(name, opts, client)
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
        
        def run
          Marvin::Logger.info "Starting up DRb Client"
          DRb.start_service
          rs = nil
          # Loop through, making sure we have a valid
          # RingFinger and then process events as they
          # appear.
          Marvin::Logger.info "Entering processing loop"
          loop do
            rs ||= Rinda::RingFinger.primary
            unless rs.blank?
              event = rs.take([:marvin_event, nil, nil, nil])
              dispatch(*event[1..-1])
            end
          end
        end
        
      end
    end
  end
end