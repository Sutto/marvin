module Marvin
  class AbstractClient
    
    # Default handlers
    
    # The default handler for all things initialization-related
    # on the client. Usually, this will send the user command,
    # set out nick, join all of the channels / rooms we wish
    # to be in and if a password is specified in the configuration,
    # it will also attempt to identify us.
    def handle_client_connected(opts = {})
      logger.info "About to handle client connected"
      # If the pass is set
      unless pass.blank?
        logger.info "Sending pass for connection"
        command :pass, pass
      end
      # IRC Connection is establish so we send all the required commands to the server.
      logger.info "Setting default nickname"
      nick nicks.shift
      logger.info "Sending user command"
      command :user, configuration.user, "0", "*", configuration.name
    rescue Exception => e
      Marvin::ExceptionTracker.log(e)
    end
    
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
      join default_channels
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
    
    # Only record joins when you've successfully joined the channel.
    def handle_incoming_join(opts = {})
      if opts[:nick] == @nickname
        channels << opts[:target]
        logger.info "Successfully joined channel #{opts[:target]}"
      end
    end
    
    # Make sure we show user server errors
    def handle_incoming_error(opts = {})
      if opts[:message].present?
        logger.info "Got ERROR Message: #{opts[:message]}"
      end
    end
    
  end
end