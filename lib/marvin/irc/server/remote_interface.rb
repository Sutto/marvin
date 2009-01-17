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
        include DRbUndumped
        
        # Attempts to find a running IRC server,
        # returning an instance of it if it exists.
        def self.primary
          DRb.start_service
          begin
            rs = Rinda::RingFinger.primary
            server = rs.read_all([:marvin_server, Marvin::Settings.distributed_namespace, nil])
            if server.empty?
              return nil
            else
              # Return the first element in the list of servers, getting it's servers instance.
              return server.first.last
            end
          rescue
            return nil
          end
        end
        
        def self.start
          DRb.start_service
          instance = self.new # Create the new instance
          begin
            rs = Rinda::RingFinger.primary
            renewer = Rinda::SimpleRenewer.new
            tuple   = [:marvin_server, Marvin::Settings.distributed_namespace, instance]
            Marvin::Logger.info "Publishing information about service to the tuplespace"
            Marvin::Logger.debug "Pushing #{tuple.inspect} to #{rs.__drburi}"
            rs.write(tuple, renewer)
          rescue
            Marvin::Logger.warn "No ring server found - remote interface not running"
          end
        end
        
        # Returns an array of all channels
        def channels
          Marvin::IRC::Server::ChannelStore.values
        end
        
        # Returns the names of all channels
        def channel_names
          Marvin::IRC::Server::ChannelStore.keys
        end
        
        # Returns the channel with the given name.
        def channel(name)
          Marvin::IRC::Server::ChannelStore[name]
        end
        
        # Send an action from a user to a specific
        # channel, using from nick as a facade.
        def message(from_nick, target, contents)
          u = (Marvin::IRC::Server::UserStore[from_nick.to_s.downcase] ||= VirtualUserConnection.new(from_nick))
          Marvin::Logger.info "#{from_nick} (#{u.inspect}) messaging #{target}: #{contents}"
          u.send_message(target, contents) unless u.blank?
        end
        
      end
    end
  end
end