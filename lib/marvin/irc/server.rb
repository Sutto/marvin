module Marvin
  module IRC
    module Server
      
      # The actual network connection
      autoload :BaseConnection,     'marvin/irc/server/base_connection'
      # An our implementations of protocol-specific stuff.
      autoload :AbstractConnection, 'marvin/irc/server/abstract_connection'
      autoload :UserConnection,     'marvin/irc/server/user_connection'
      autoload :ServerConnection,   'marvin/irc/server/server_connection'
      
      # call start_server w/ the default options
      # and inside an EM::run block.
      def self.run
        EventMachine::run do
          #start_server
        end
      end
      
      # Starts the server with a set of given options
      def self.start_server(opts = {})
        EventMachine::start_server (opts[:host] || "localhost"), (opts[:port] || 6667), BaseConnection, opts
      end
      
    end
  end
end