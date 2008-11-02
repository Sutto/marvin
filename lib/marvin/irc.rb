module Marvin
  module IRC
    autoload :Client,         'marvin/irc/client'
    autoload :Event,          'marvin/irc/event'
    autoload :SocketClient,   'marvin/irc/socket_client'
    autoload :AbstractServer, 'marvin/irc/abstract_server'
    autoload :BaseServer,     'marvin/irc/base_server'
  end
end