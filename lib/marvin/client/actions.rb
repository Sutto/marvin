module Marvin
  class AbstractClient
   
    ## General IRC Functions / Actions
    
    # Sends a specified command to the server.
    # Takes name (e.g. :privmsg) and all of the args.
    # Very simply formats them as a string correctly
    # and calls send_data with the results.
    def command(name, *args)
      # First, get the appropriate command
      name = name.to_s.upcase
      args = args.flatten.compact
      send_line "#{name} #{args.join(" ").strip}\r\n"
    end
    
    def join(channel)
      channel = Marvin::Util.channel_name(channel)
      # Record the fact we're entering the room.
      # TODO: Refactor to only add the channel when we receive confirmation we've joined.
      channels << channel
      command :JOIN, channel
      logger.info "Joined channel #{channel}"
      dispatch :outgoing_join, :target => channel
    end
    
    def part(channel, reason = nil)
      channel = Marvin::Util.channel_name(channel)
      if channels.include?(channel)
        command :part, channel, Marvin::Util.last_param(reason)
        dispatch :outgoing_part, :target => channel, :reason => reason
        logger.info "Parted from room #{channel}#{reason ? " - #{reason}" : ""}"
      else
        logger.warn "Tried to part from #{channel} when no JOIN was recorded."
      end
    end
    
    def quit(reason = nil)
      @disconnect_expected = true
      logger.info "Preparing to part from #{channels.size} channels"
      channels.to_a.each do |chan|
        logger.info "Parting from #{chan}"
        part chan, reason
      end
      logger.info "Parted from all channels, quitting"
      command  :quit
      dispatch :outgoing_quit
      # Remove the connections from the pool
      connections.delete(self)
      logger.info  "Quit from server"
    end
    
    def msg(target, message)
      command :privmsg, target, Marvin::Util.last_param(message)
      logger.info "Message sent to #{target}: #{message}"
      dispatch :outgoing_message, :target => target, :message => message
    end
    
    def action(target, message)
      action_text = Marvin::Util.last_param "\01ACTION #{message.strip}\01"
      command :privmsg, target, action_text
      dispatch :outgoing_action, :target => target, :message => message
      logger.info "Action sent to #{target} - #{message}"
    end
    
    def pong(data)
      command :pong, data
      dispatch :outgoing_pong
      logger.info "PONG sent to #{data}"
    end
    
    def nick(new_nick)
      logger.info "Changing nickname to #{new_nick}"
      command :nick, new_nick
      @nickname = new_nick
      dispatch :outgoing_nick, :new_nick => new_nick
      logger.info "Nickname changed to #{new_nick}"
    end
    
  end
end