module Marvin::IRC::Server
  class UserConnection < AbstractConnection
    
    attr_accessor :nick, :host, :ident, :prefix
    
  end
end