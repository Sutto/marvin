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
      "#{@nick}!n=rruser@relayrelay.com"
    end
    
    def notify(*args)
      Marvin::Logger.debug "Virtual User #{self.nick} got notify w/ #{args.inspect}"
    end
    
    # Notify the remote handler we've received a message
    def message(user, message, virtual = false)
      dispatch :received_message, :user => user, :message => message, :target => self unless virtual
    end
    
    def send_message(target, message)
      t = target_from(target)
      Marvin::Logger.debug "DRb Message from #{self.nick} to #{t.inspect}: #{message.inspect}"
      if t.blank?
        Marvin::Logger.debug "Target not found"
        return nil
      else
        Marvin::Logger.debug "Sending message to #{t.inspect}"
        return t.message(self, message, true)
      end
    end
    
    def reclaim!
      self.channels.each { |c| c.part(self, "Reclaiming nick for virtual user...") }
      Marvin::IRC::Server::UserStore.delete(self.nick.downcase)
    end
    
    def join(channel)
      return nil if channel !~ CHANNEL
      chan = (Marvin::IRC::Server::ChannelStore[channel.downcase] ||= Marvin::IRC::Server::Channel.new(channel))
      if chan.join(self)
        @channels << channel
        return chan
      end
    end
    
    class << self
      
      def claimed?(nick)
        Marvin::IRC::Server::UserStore.virtual?(nick)
      end
      
      def claim(nick)
        unless Marvin::IRC::Server::UserStore[nick.downcase].blank?
          return(Marvin::IRC::Server::UserStore[nick.downcase] ||= Marvin::IRC::Server::VirtualUserConnection.new(nick))
        end
      end
      
    end
    
    private
    
    def target_from(target)
      if target =~ CHANNEL
        c = Marvin::IRC::Server::ChannelStore[target.downcase]
        c = join(target) if c.nil? || !c.member?(self)
        return c
      else
        return Marvin::IRC::Server::UserStore[target.downcase] ||= Marvin::IRC::Server::VirtualUserConnection.new(target)
      end
    end
    
  end
end