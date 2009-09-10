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
      args = args.flatten
      args << util.last_param(args.pop)
      send_line "#{name} #{args.compact.join(" ").strip}\r\n"
    end
    
    # Join one or more channels on the current server
    # e.g.
    #   client.join "#marvin-testing"
    #   client.join ["#marvin-testing", "#rubyonrails"]
    #   client.join "#marvin-testing", "#rubyonrails"
    def join(*channels_to_join)
      channels_to_join = channels_to_join.flatten.map { |c| util.channel_name(c) }
      # If you're joining multiple channels at once, we join them together
      command :JOIN, channels_to_join.join(",")
      channels_to_join.each { |channel| dispatch :outgoing_join, :target => channel }
      logger.info "Sent JOIN for channels #{channels_to_join.join(", ")}"
    end
    
    # Parts a channel, with an optional reason
    # e.g.
    #    part "#marvin-testing"
    #    part "#marvin-testing", "Ninjas stole by felafel"
    def part(channel, reason = nil)
      channel = util.channel_name(channel)
      # Send the command anyway, even if we're not a
      # a recorded member something might of happened.
      command :part, channel, reason
      if channels.include?(channel)
        dispatch :outgoing_part, :target => channel, :reason => reason
        logger.info "Parted channel #{channel} - #{reason.present? ? reason : "Non given"}"
      else
        logger.warn "Parted channel #{channel} but wasn't recorded as member of channel"
      end
    end
    
    # Quites from a server, first parting all channels if a second
    # argument is passed as true
    # e.g.
    #    quit
    #    quit "Going to grab some z's"
    def quit(reason = nil, part_before_quit = false)
      @disconnect_expected = true
      # If the user wants to part before quitting, they should
      # pass a second, true, parameter
      if part_before_quit
        logger.info "Preparing to part from channels before quitting"
        channels.to_a.each { |chan| part(chan, reason) }
        logger.info "Parted from all channels, quitting"
      end
      command :quit, reason
      dispatch :outgoing_quit
      # Remove the connections from the pool
      connections.delete(self)
      logger.info  "Quit from #{host_with_port}"
    end
    
    # Sends a message to a target (either a channel or a user)
    # e.g.
    #    msg "#marvin-testing", "Hello there!"
    #    msg "SuttoL", "Hey, I'm playing with marvin!"
    def msg(target, message)
      command :privmsg, target, message
      dispatch :outgoing_message, :target => target, :message => message
      logger.info "Message #{target} - #{message}"
    end
    
    # Does a CTCP action in a channel (equiv. to doing /me in most IRC clients)
    # e.g.
    #    action "#marvin-testing", "is about to sleep"
    #    action "SuttoL", "is about to sleep"
    def action(target, message)
      command :privmsg, target, "\01ACTION #{message.strip}\01"
      dispatch :outgoing_action, :target => target, :message => message
      logger.info "Action sent to #{target} - #{message}"
    end
    
    def pong(data)
      command :pong, data
      dispatch :outgoing_pong
      logger.info "PONG sent to #{host_with_port} w/ data - #{data}"
    end
    
    def nick(new_nick)
      logger.info "Changing nick to #{new_nick}"
      command :nick, new_nick
      @nickname = new_nick
      dispatch :outgoing_nick, :new_nick => new_nick
      logger.info "Nick changed to #{new_nick}"
    end
    
  end
end