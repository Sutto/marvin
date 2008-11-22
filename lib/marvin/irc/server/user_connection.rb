module Marvin::IRC::Server
  class UserConnection < AbstractConnection
    
    attr_accessor :nick, :host, :ident, :prefix
    
    # Notify is essentially command
    # BUT it requires that the prefix is
    # set.
    def notify(command, *args)
    end
    
  end
end