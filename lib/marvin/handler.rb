module Marvin
  module Handler
    
    # Received a given +message+ with a set of default
    # +opts+ (defaulting back to an empty hash), which
    # will be used to perform some sort of action.
    def handle(message, opts = {})
      Marvin::Logger.debug "NOP handle - got message #{message.inspect}"
    end
    
  end
end