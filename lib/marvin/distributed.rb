require 'drb'
require 'rinda/ring'


module Marvin
  # Distributed tools for Marvin instances.
  # Uses a tuple space etc + DRb to provide
  # IRC Processing across the network.
  module Distributed
    autoload :RingServer,      'marvin/distributed/ring_server'
    autoload :DispatchHandler, 'marvin/distributed/dispatch_handler'
    autoload :DRbClient,       'marvin/distributed/drb_client'
  end
end