module Marvin::IRC::Server
  class UserConnection < AbstractConnection
    
    include User::HandleMixin
    
    CHANNEL = /^(\&\#)+/
    
    attr_accessor :nick, :host, :user, :prefix, :password, :mode,
                  :real_name, :nick_attempts, :channels, :ping_count
    
    def initialize(opts = {})
      super
      @nick_attempts = 0
      @channels      = []
      @ping_count    = 0
    end
    
    # Notify is essentially command BUT it
    # requires that the prefix is set.
    def notify(command, *args)
      opts = args.extract_options!
      return if opts[:prefix].blank?
      command command, *(args << opts)
    end
    
    # Notification messages
    
    def message(user, message)
      notify :PRIVMSG, @nick, ":#{message}", :prefix => user.prefix
      dispatch :outgoing_message, :user => user, :message => message, :target => self
    end
    
    def notice(user, message)
      notify :NOTICE, @nick, ":#{message}", :prefix => user.prefix
      dispatch :outgoing_notice, :user => user, :message => message, :target => self
    end
    
    # Get the user / channel targeted by a particular request.
    
    def target_from(target)
      case target
      when CHANNEL
        chan = ChannelStore[target.downcase]
        if chan.nil?
          rpl :NOSUCHNICK, target, ":No such nick/channel"
        elsif !chan.member?(self)
          err :CANNOTSENDTOCHAN, target, ":Cannot send to channel"
        else
          return chan
        end
      else
        user = UserStore[target.downcase]
        if user.nil?
          err :NOSUCHNICK, target, ":No suck nick/channel"
        else
          return user
        end
      end
    end
    
    # Implementations for connect / disconnect
    
    def process_connect
      super
    end
    
    def process_disconnect
      super
    end
    
    def kill_connection!
      @connection.kill_connection!
    end
    
    private
    
    def welcome_if_complete!
      update_prefix!
      # send_welcome
    end
    
    def update_prefix!
      @prefix = "#{@nick}!~#{@user}@#{peer_name}" if details_complete?
    end
    
    def details_complete?
      !@nick.nil? && !@user.nil?
    end
    
  end
end