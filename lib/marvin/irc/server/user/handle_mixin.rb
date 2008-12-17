module Marvin::IRC::Server::User::HandleMixin
  
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
    if !nick.blank? && !Marvin::IRC::Server::UserStore.nick_taken?(nick.downcase)
      if !(new_nick = @nick.nil?)
        logger.info "Reclaiming nick (if taken)"
        Marvin::IRC::Server::UserStore.reclaim(nick)
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
      Marvin::IRC::Server::UserStore.delete(@nick.downcase) unless @nick.blank?
      Marvin::IRC::Server::UserStore[nick.downcase] = self
      # Change the nick and reset the number of attempts
      @nick = nick
      @nick_attempts = 0
      # Finally, update the prefix.
      update_prefix!
      welcome_if_complete! if new_nick
    elsif Marvin::IRC::Server::UserStore[nick.downcase] != self
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
      if channel !~ Marvin::IRC::Server::UserConnection::CHANNEL
        logger.debug "Attempted to join invalid channel name '#{channel}'"
        err :NOSUCHCHANNEL, channel, ":That channel doesn't exist"
        dispatch :invalid_channel_name, :channel => channel, :client => self
        return
      end
      chan = (Marvin::IRC::Server::ChannelStore[channel.downcase] ||= Marvin::IRC::Server::Channel.new(channel))
      if chan.join(self)
        rpl :TOPIC, channel, ":#{chan.topic.blank? ? "There is no topic" :  chan.topic}"
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
    unless (t = target_from(opts[:target])).blank?
      t.message self, opts[:message]
    end
  end

  def handle_incoming_notice(opts = {})
    return if @prefix.blank?
    unless (t = target_from(opts[:target])).blank?
      t.notice self, opts[:message]
    end
  end

  def handle_incoming_part(opts = {})
    t = opts[:target].downcase
    if !(chan = Marvin::IRC::Server::ChannelStore[t]).blank?
      if chan.part(self, opts[:message])
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
  
  def handle_incoming_topic(opts = {})
    return if @prefix.blank? || opts[:target].blank?
    c = Marvin::IRC::Server::ChannelStore[opts[:target].downcase]
    return if c.blank?
    if !@channels.include?(c)
      err :NOTONCHANNEL, opts[:target], ":Not a member of that channel"
    elsif opts[:topic].blank?
      t = c.topic
      if t.blank?
        rpl :NOTOPIC, c.name, ":No topic is set"
      else
        rpl :TOPIC, c.name, ":#{t}"
      end
    else
      c.topic self, opts[:topic].strip
    end
  end
  
end