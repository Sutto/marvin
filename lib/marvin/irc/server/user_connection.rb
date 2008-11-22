module Marvin::IRC::Server
  class UserConnection < AbstractConnection
    
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
    
    def handle_incoming_pass(opts = {})
      @password = opts[:password]
    end
    
    def handle_incoming_user(opts = {})
      @user      = opts[:user]
      @mode      = opts[:mode]
      @real_name = opts[:real_name]
      welcome_if_complete!
    end

    def handle_incoming_nick(opts = {})
      nick = opts[:new_nick]
      if !nick.blank? && !UserStore.nick_taken?(nick.downcase)
        if @nick.nil?
          logger.debug "Welcoming new user, assuming their nick is complete"
          welcome_if_complete!
        else
          logger.debug "Notifying all users of nick change: #{@nick} => #{nick}"
          # Get all users and let them now we've changed nick from @nick to nick
          users = [self]
          @channels.each do |c|
            users += c.members.values
          end
          users.uniq.each { |u| u.notify :NICK, nick, :prefix => prefix }
          dispatch :outgoing_nick, :nick => @nick, :new_nick => nick
        end
        # Update the store values
        UserStore.delete(@nick.downcase) unless @nick.blank?
        UserStore[nick.downcase] = self
        # Change the nick and reset the number of attempts
        @nick = nick
        @nick_attempts = 0
        # Finally, update the prefix.
        update_prefix!
      elsif UserStore[nick.downcase] != self
        # The nick is taken
        # TODO: Remove hard coded nick attempts limit
        if @nick_attempts > 5
          # Handle abort here.
          logger.debug "User has gone over nick attempt limits - Killing connection."
          kill_connection!
          dispatch :outgoing_nick_killed, :client => self
        else
          logger.debug "Noting users nick is taken, warning"
          err :NICKNAMEINUSE, "*", nick, ":Nickname is already in use."
          @nick_attempts += 1
        end
      end
    end

    def handle_incoming_join(opts = {})
      return if @prefix.blank?
      opts[:target].split(",").each do |channel|
        # If the channel name is invalud, let the user known and dispatch
        # the correct event.
        if channel !~ CHANNEL
          logger.debug "Attempted to join invalid channel name '#{channel}'"
          err :NOSUCHCHANNEL, channel, ":That channel doesn't exist"
          dispatch :invalid_channel_name, :channel => channel, :client => self
          return
        end
        chan = (ChannelStore[channel.downcase] ||= Channel.new(channel))
        if chan.join(self)
          rpl :TOPIC, channel, ":#{chan.topic}"
          rpl :NAMREPLY, "=", channel, ":#{chan.members.map { |m| m.nick }.join(" ")}"
          rpl :ENDOFNAMES, channel, ":End of /NAMES list."
          @channels << chan
        else
          logger.debug "Couldn't join channel '#{channel}'"
        end
      end
    end
    
    def handle_incoming_ping(opts = {})
      command :PONG, ":#{opts[:data]}"
    end
    
    def handle_incoming_pong(opts = {})
      # Decrease the ping count.
      @ping_count -= 1
      @ping_count = 0 if @ping_count < 0
      logger.debug "Got pong: #{opts[:data]}"
    end

    def handle_incoming_message(opts = {})
      return if @prefix.blank?
      case opts[:target]
      when CHANNEL
        chan = ChannelStore[opts[:target].downcase]
        if chan.nil?
          rpl :NOSUCHNICK, opts[:target], ":No such nick/channel"
        elsif !channel.member?(self)
          err :CANNOTSENDTOCHAN, opts[:target], ":Cannot send to channel"
        else
          chan.message self, ":#{opts[:message]}"
        end
      else
        user = UserStore[opts[:target].downcase]
        if user.nil?
          err :NOSUCHNICK, opts[:target], ":No suck nick/channel"
        else
          user.notify :PRIVMSG, opts[:target], ":#{opts[:message]}", :prefix => @prefix
          dispatch :outgoing_message, :target => opts[:target], :client => self, :message => opts[:message]
        end
      end
    end

    def handle_incoming_notice(opts = {})
      return if @prefix.blank?
      case opts[:target]
      when CHANNEL
        chan = ChannelStore[opts[:target].downcase]
        if chan.nil?
          rpl :NOSUCHNICK, opts[:target], ":No such nick/channel"
        elsif !channel.member?(self)
          err :CANNOTSENDTOCHAN, opts[:target], ":Cannot send to channel"
        else
          chan.notice self, ":#{opts[:message]}"
        end
      else
        user = UserStore[opts[:target].downcase]
        if user.nil?
          err :NOSUCHNICK, opts[:target], ":No suck nick/channel"
        else
          user.notify :NOTICE, opts[:target], ":#{opts[:message]}", :prefix => @prefix
          dispatch :outgoing_notice, :target => opts[:target], :client => self, :message => opts[:message]
        end
      end
    end

    def handle_incoming_part(opts = {})
      t = opts[:target].downcase
      if !(chan = ChannelStore[t]).blank?
        if chan.part(user, opts[:message])
          @channels.delete(chan)
        else
          err :NOTONCHANNEL, opts[:target], ":Not a member of that channel"
        end
      else
        err :NOSUCHNICK, opts[:target], ":No such nick/channel"
      end
    end

    def handle_incoming_quit(opts = {})
      return unless @alive
      @alive = false
      @channels.each { |c| c.quit(self, opts[:message]) }
      kill_connection!
    end

    # Notification messages
    
    def message(user, message)
      notify :PRIVMSG, @nick, ":#{message}", :prefix => user.prefix
      dispatch :outgoing_message, :client => user, :message => message, :nick => @nick
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