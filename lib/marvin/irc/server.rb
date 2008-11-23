module Marvin
  module IRC
    module Server
      
      # Server utilities
      autoload :NamedStore,         'marvin/irc/server/named_store'
      
      # Store each user
      UserStore = NamedStore.new(:nicks, :user) do
        def nick_taken?(nick)
          has_key?(nick)
        end
        
        def each_user_except(user)
          self.each_user do |u|
            yield u unless user == u 
          end
        end
      end
      
      # Store each channel
      ChannelStore = NamedStore.new(:names, :channel)
      
      autoload :Channel,            'marvin/irc/server/channel'
      # The actual network connection
      autoload :BaseConnection,     'marvin/irc/server/base_connection'
      # An our implementations of protocol-specific stuff.
      autoload :AbstractConnection, 'marvin/irc/server/abstract_connection'
      autoload :UserConnection,     'marvin/irc/server/user_connection'
      autoload :ServerConnection,   'marvin/irc/server/server_connection'
      # Extensions for each part
      autoload :User,               'marvin/irc/server/user'
      
      # call start_server w/ the default options
      # and inside an EM::run block.
      def self.run
        EventMachine::run do
          #start_server
        end
      end
      
      # Starts the server with a set of given options
      def self.start_server(opts = {})
        opts[:started_at] ||= Time.now
        EventMachine::start_server((opts[:host] || "localhost"), (opts[:port] || 6667), BaseConnection, opts)
      end
      
    end
  end
end