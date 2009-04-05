# A reference logger example
class SimpleLogger < Marvin::LoggingHandler
  
  def setup_logging
    logger.warn "Setting up the client"
  end
  
  def teardown_logging
    logger.warn "Tearing down the logger"
  end
  
  def log_incoming(server, nick, target, message)
    logger.fatal "[INCOMING] #{server} (#{target}) #{nick}: #{message}"
  end

  def log_outgoing(server, nick, target, message)
    logger.fatal "[OUTGOING] #{server} (#{target}) #{nick}: #{message}"
  end

  def log_message(server, nick, target, message)
    logger.fatal "[MESSAGE]  #{server} (#{target}) #{nick}: #{message}"
  end
  
end