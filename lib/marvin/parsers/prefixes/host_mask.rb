module Marvin
  module Parsers
    module Prefixes
      # A Generic host mask prefix for a message.
      class HostMask
        attr_accessor :nickname, :user, :host
        
        def initialize(nickname = nil, user = nil, host = nil)
          self.nickname = nickname || ""
          self.user     = user || ""
          self.host     = host || ""
        end
        
        # Convert it to a usable hash.
        def to_hash
          {:nick => @nickname.freeze, :ident => @user.freeze, :host => @host.freeze}
        end
        
        # Converts it back to a nicer form / a string.
        def to_s
          str = ""
          str << @nickname.to_s
          str << "!#{@user}" unless @user.blank?
          str << "@#{@host}" unless @host.blank?
        end
        
      end
    end
  end
end