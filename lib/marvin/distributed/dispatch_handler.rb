require 'rinda/ring'
require 'rinda/tuplespace'

Marvin::AbstractClient.class_eval do
  include DRbUndumped
end

module Marvin
  module Distributed
    class DispatchHandler < Marvin::Base
      
      def self.setup
        return if @setup
        DRb.start_service
        @setup = true
      end
      
      self.setup
      
      def ring_server
        @@rs ||= Rinda::RingFinger.primary
      end
      
      def handle(message, options)
        super(message, options)
        rs = self.ring_server
        if rs.nil?
          logger.warn "Ring server couldn't be found - woops!"
        else
          rs.write([:marvin_event, message, options, self.client])
        end
      end
      
      def self.register!(*args)
        # DO NOT register if this is not a normal client.
        return unless Marvin::Loader.type == :client
        super
      end
      
    end
  end
end