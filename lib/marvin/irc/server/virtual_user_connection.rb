module Marvin::IRC::Server
  class VirtualUserConnection
    include Marvin::Dispatchable
    
    CHANNEL = /^[\&\#]+/
    
    attr_accessor :nick, :channels
    
    def initialize(nick)
      self.nick     = nick
      self.channels = []

    end
    
    def prefix
      "#{@nick}!n=relayrelayuser@relayrelay.com"
    end
    
    # Notify the remote handler we've received a message
    def message(user, message)
      dispatch :received_message, :user => user, :message => message, :target => self
    end
    
    def send_message(target, contents)
      t = target_from(target)
      return t.blank? ? nil : t.message(self, contents)
    end
    
    def reclaim!
      self.channels.each { |c| c.part(self, "Reclaiming nick for virtual user...") }
      Marvin::IRC::Server::UserStore.delete(self.nick.downcase)
    end
    
    def join(channel)
      return nil if channel !~ CHANNEL
      chan = (Marvin::IRC::Server::ChannelStore[channel.downcase] ||= Marvin::IRC::Server::Channel.new(channel))
      if chan.join(self)
        self.channels << channel
        return chan
      end
    end
    
    private
    
    def target_from(target)
      if target =~ CHANNEL
        c = Marvin::IRC::Server::ChannelStore[target.downcase]
        c = join(target) if c.nil? || !c.member?(self)
        return c
      else
        return Marvin::IRC::Server::UserStore[target.downcase]
      end
    end
    
  end
end