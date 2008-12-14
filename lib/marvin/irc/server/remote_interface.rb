require 'drb'
require 'rinda/ring'
module Marvin
  module IRC
    module Server
      
      # Make sure that a proxy object is used vs. the real thing.
      [Channel, AbstractConnection, User, NamedStore].each do |c|
        c.class_eval { include DRbUndumped }
      end
      
      # A DRb interface to post / receive messages from the
      # a running server instance. Used for things such as
      # posting status updated directly on the server.
      class RemoteInterface
        
        def self.start
          instance = self.new # Create the new instance
          rs = Rinda::RingFinger.primary
          unless rs.blank?
            renewer = Rinda::SimpleRenewer.new
            tuple   = [:marvin_server, Marvin::Settings.distributed_namespace, self]
            Marvin::Logger.info "Publishing information about service to the tuplespace"
            rs.write(tuple, renewer)
          end
        end
        
        # Returns an array of all channels
        def channels
          Marvin::IRC::Server::ChannelStore.values
        end
        
        # Returns the names of all channels
        def channel_names
          Marvin::IRC::Server::ChannelStore.values.map { |c| c.name.dup }
        end
        
        # Returns the channel with the given name.
        def channel(name)
          Marvin::IRC::Server::ChannelStore[name]
        end
        
        # Send an action from a user to a specific
        # channel, using from nick as a facade.
        def message(from_nick, target, contents)
        end
        
      end
    end
  end
end