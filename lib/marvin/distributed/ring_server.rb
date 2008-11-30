require 'rinda/ring'
require 'rinda/tuplespace'

module Marvin
  module Distributed
    class RingServer
      
      attr_accessor :tuple_space, :ring_server
      cattr_accessor :logger
      self.logger = Marvin::Logger
      
      def initialize
        self.tuple_space = Rinda::TupleSpace.new
        if Marvin::Settings.log_level == :debug
          observer = self.tuple_space.notify('write', [:marvin_event, nil, nil, nil])
          Thread.start do
            observer.each do |i|
              event_name, args = i[1][1..2]
              Marvin::Logger.logger.debug "Marvin event added - #{event_name.inspect} w/ #{args.inspect}"
            end
          end
        end
        self.ring_server = Rinda::RingServer.new(self.tuple_space)
      end
      
      def self.run
        begin
          logger.info "Starting up DRb"
          drb_server = DRb.start_service
          logger.info "Creating TupleSpace & Ring Server Instances - Running on #{DRb.uri}"
          self.new
          logger.info "Started - Joining thread."
          DRb.thread.join
        rescue
          logger.fatal "Error starting ring server - please ensure another instance isn't already running."
        end
      end
      
    end
  end
end