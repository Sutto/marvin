module Marvin
  # A generic class to make it easy to implement loggers
  # in marvin. Users only need to implement 1 method for simple
  # logging but have control to do more. Please note that
  # if you want it correctly log the order of messages, it
  # needs to be the first registered handler, otherwise
  # outgoing messages will be processed before incoming ones.
  class LoggingHandler < CommandHandler
    
    on_event :incoming_message do
      if should_log?
        log_incoming(@server, options.nick, options.target, options.message)
        log_message(@server, options.nick, options.target, options.message)
      end
    end
    
    on_event :outgoing_message do
      if should_log?
        log_outgoing(@server, @nick, options.target, options.message)
        log_message(@server, @nick, options.target, options.message)
      end
    end
    
    on_event :client_connected do
      @server = self.client.host_with_port
      @nick   = self.client.nickname
      setup_logging
    end

    on_event :client_disconnected do
      teardown_logging
    end
    
    on_event :outgoing_nick do
      @nick = options.new_nick
    end
    
    # Called when the client connects, over ride it to
    # do any of your specific setup.
    def setup_logging
      # NOP
    end
    
    # Called when the client disconnects, over ride it to
    # do any of your specific teardown.
    def teardown_logging
      # NOP
    end
    
    # Called before logging a message for conditional logging.
    # Override with your implementation specific version.
    def should_log?
      true
    end
    
    # Log an incoming message (i.e. from another user)
    # Note that +server+ is in the port host:port, 
    # nick is the origin nick and target is either
    # a channel or the bots nick (if PM'ed)
    def log_incoming(server, nick, target, message)
    end
    
    # Log an outgoing message (i.e. from this user)
    # Note that +server+ is in the port host:port, 
    # nick is the bots nick and target is either
    # a channel or the user the bot is replying to.
    def log_outgoing(server, nick, target, message)
    end
    
    # Logs a message - used when you want to log
    # both incoming and outgoing messages
    def log_message(server, nick, target, message)
    end
    
  end
end