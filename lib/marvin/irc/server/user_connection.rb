module Marvin::IRC::Server
  class UserConnection < AbstractConnection
    USER_MODES    = "aAbBcCdDeEfFGhHiIjkKlLmMnNopPQrRsStUvVwWxXyYzZ0123459*@"
    CHANNEL_MODES = "bcdefFhiIklmnoPqstv"
    CHANNEL       = /^[\&\#]+/
    
    include User::HandleMixin
    
    attr_accessor :nick, :host, :user, :prefix, :password, :mode,
                  :real_name, :nick_attempts, :channels, :ping_count
    
    def inspect
      "#<Marvin::IRC::Server::UserConnection nick='#{@nick}' host='#{@host}' real_name='#{@real_name}' channels=[#{self.channels.map { |c| c.name.inspect}.join(", ")}]>"
    end
    
    def initialize(base, buffer = [])
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
    
    def send_message(target, message)
      t = target_from(target)
      logger.debug "Sending #{t.inspect} #{message.inspect} from #{self.inspect}"
      t.message(self, message) unless t.blank?
    end
    
    def message(user, message, virtual = false)
      notify :PRIVMSG, @nick, ":#{message}", :prefix => user.prefix, :virtual => virtual
      dispatch :outgoing_message, :user => user, :message => message, :target => self, :virtual => virtual
    end
    
    def notice(user, message)
      notify :NOTICE, @nick, ":#{message}", :prefix => user.prefix
      dispatch :outgoing_notice, :user => user, :message => message, :target => self
    end
    
    # Get the user / channel targeted by a particular request.
    
    def target_from(target)
      case target
      when CHANNEL
        chan = Marvin::IRC::Server::ChannelStore[target.downcase]
        if chan.nil?
          rpl :NOSUCHNICK, target, ":No such nick/channel"
        elsif !chan.member?(self)
          err :CANNOTSENDTOCHAN, target, ":Cannot send to channel"
        else
          return chan
        end
      else
        user = Marvin::IRC::Server::UserStore[target.downcase]
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
    
    protected
    
    def welcome_if_complete!
      update_prefix!
      # Next, send the MOTD and other misc. stuff
      return if @welcomed || @prefix.blank?
      rpl :WELCOME,   @nick, ":Welcome to Marvin Server - #{@prefix}"
      rpl :YOURHOST,  @nick, ":Your host is #{server_host}, running version #{Marvin.version}"
      rpl :CREATED,   @nick, ":This server was created #{@connection.started_at}"
      rpl :MYINFO,    @nick, ":#{server_host} #{Marvin.version} #{USER_MODES} #{CHANNEL_MODES}"
      rpl :MOTDSTART, @nick, ":- MOTD"
      rpl :MOTD,      @nick, ":- Welcome to Marvin Server, a Ruby + EventMachine ircd."
      rpl :ENDOFMOTD, @nick, ":- End of /MOTD command."
      @welcomed = true
    end
    
    def update_prefix!
      @prefix = "#{@nick}!n=#{@user}@#{peer_name}" if details_complete?
    end
    
    def details_complete?
      !@nick.nil? && !@user.nil?
    end
    
    def server_host
      @connection.host
    end
    
    def server_port
      @connection.port
    end
    
    def rpl(number, *args)
      numeric Marvin::IRC::Replies["RPL_#{number.to_s.upcase}"], *args
    end
    
    def err(number, *args)
      numeric Marvin::IRC::Replies["ERR_#{number.to_s.upcase}"], *args
    end
    
    def numeric(number, *args)
      args << {} unless args[-1].is_a?(Hash)
      args[-1][:prefix] ||= server_host
      args.unshift(@nick) unless args.first == @nick
      command(number.to_s, *args)
    end
    
  end
end