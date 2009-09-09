module Marvin
  class AbstractClient
    
    # handle a bunch of default events that happen at a connection
    # level instead of a per-app level.
    
    # The default response for PING's - it simply replies
    # with a PONG.
    def handle_incoming_ping(opts = {})
      logger.info "Received Incoming Ping - Handling with a PONG"
      pong(opts[:data])
    end
    
    # TODO: Get the correct mapping for a given
    # Code.
    def handle_incoming_numeric(opts = {})
      case opts[:code]
        when Marvin::IRC::Replies[:RPL_WELCOME]
          handle_welcome
        when Marvin::IRC::Replies[:ERR_NICKNAMEINUSE]
          handle_nick_taken
        when Marvin::IRC::Replies[:RPL_TOPIC]
          handle_channel_topic
      end
      code = opts[:code].to_i
      args = Marvin::Util.arguments(opts[:data])
      dispatch :incoming_numeric_processed, :code => code, :data => args
    end
    
    def handle_welcome
      logger.info "Welcome received from server"
      # If a password is specified, we will attempt to message
      # NickServ to identify ourselves.
      say ":IDENTIFY #{self.configuration.password}", "NickServ" if configuration.password.present?
      # Join the default channels IF they're already set
      # Note that Marvin::IRC::Client.connect will set them AFTER this stuff is run.
      default_channels.each { |c| join(c) }
    end
    
    # The default handler for when a users nickname is taken on
    # on the server. It will attempt to get the nicknickname from
    # the nicknames part of the configuration (if available) and
    # will then call #nick to change the nickname.
    def handle_nick_taken
      logger.info "Nickname '#{nickname}' on #{server} taken, trying next." 
      logger.info "Available Nicknames: #{nicks.empty? ? "None" : nicks.join(", ")}"
      if !nicks.empty?
        logger.info "Getting next nickname to switch"
        next_nick = nicks.shift # Get the next nickname
        logger.info "Attemping to set nickname to '#{next_nick}'"
        nick next_nick
      else
        logger.fatal "No Nicknames available - QUITTING"
        quit
      end
    end
    
    def handle_channel_topic
      # TODO: Check if the channel is one we attempted to join.
      # If it is, we move it from the 'pending_channels' list to
      # the list of channels we are currently in.
    end
  end
end