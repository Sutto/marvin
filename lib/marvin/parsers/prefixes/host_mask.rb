module Marvin
  module Parsers
    module Prefixes
      # A Generic host mask prefix for a message.
      class HostMask
        attr_accessor :nick, :user, :host
        
        def initialize(nick = nil, user = nil, host = nil)
          @nick = nick || ""
          @user = user || ""
          @host = host || ""
        end
        
        # Convert it to a usable hash.
        def to_hash
          {
            :nick => @nick.dup.freeze,
            :ident => @user.dup.freeze,
            :host => @host.dup.freeze
          }
        end
        
        # Converts it back to a nicer form / a string.
        def to_s
          str = ""
          str << @nick.to_s
          str << "!#{@user}" unless @user.blank?
          str << "@#{@host}" unless @host.blank?
          str
        end
        
      end
    end
  end
end