module Marvin
  class DRBHandler
    
    attr_accessor :port
    
    # Will do the appropriate things to dispatch
    # a message to the different DRB clients.
    def handle(message, opts = {})
    end

  end
end