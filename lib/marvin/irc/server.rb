module Marvin
  module IRC
    module Server
      
      # Server utilities
      autoload :NamedStore,         'marvin/irc/server/named_store'
      
      # Store each user
      UserStore = NamedStore.new(:nicks, :user) do
        
        def virtual?(nick)
          self[nick].is_a?(Marvin::IRC::Server::VirtualUserConnection)
        end
        
        def reclaim(nick)
          if has_key?(nick) && virtual?(nick)
            self[nick].reclaim!
          end
        end
        
        # Nick is not taken when 
        def nick_taken?(nick)
          has_key?(nick) && !virtual(nick)
        end
        
        def each_user_except(user)
          self.each_user { |u| yield u unless user == u }
        end
      end
      
      # Store each channel
      ChannelStore = NamedStore.new(:names, :channel)
      
      autoload :RemoteInterface,       'marvin/irc/server/remote_interface'
      autoload :Channel,               'marvin/irc/server/channel'
      # The actual network connection
      autoload :BaseConnection,        'marvin/irc/server/base_connection'
      # An our implementations of protocol-specific stuff.
      autoload :VirtualUserConnection, 'marvin/irc/server/virtual_user_connection'
      autoload :AbstractConnection,    'marvin/irc/server/abstract_connection'
      autoload :UserConnection,        'marvin/irc/server/user_connection'
      autoload :ServerConnection,      'marvin/irc/server/server_connection'
      # Extensions for each part
      autoload :User,                  'marvin/irc/server/user'
      
      # call start_server w/ the default options
      # and inside an EM::run block.
      def self.run
        Marvin::IRC::Server::RemoteInterface.start
        EventMachine::run do
          Marvin::Logger.info "Starting server..."
          start_server :bind_addr => "0.0.0.0"
        end
      end
      
      # Starts the server with a set of given options
      def self.start_server(opts = {})
        opts[:started_at] ||= Time.now
        opts[:host]       ||= self.host_name
        opts[:port]       ||= 6667
        EventMachine::start_server(opts[:bind_addr] || opts[:host], opts[:port], BaseConnection, opts)
      end
      
      def self.host_name
        @@host_name ||= Socket.gethostname
      end
      
    end
  end
end