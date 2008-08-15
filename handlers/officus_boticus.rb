class OfficusBoticus < Marvin::CommandHandler
  
  class_inheritable_accessor :connection, :setup
  attr_accessor :listening, :users
  
  def initialize
    super
    logger.debug "Setting up OfficusBoticus"
    self.setup!
    self.users = {}
  end
  
  # Control
  
  exposes :listen, :earmuffs
  
  def listen(data)
    unless listening?
      @listening = true
      reply "Busted! I heard _everything_ you said ;)"
    else
      reply "Uh, You never asked me to put my earmuffs on?"
    end
  end
  
  def earmuffs(data)
    if listening?
      @listening = false
      reply "Oh hai, I'm not listening anymore."
    else
      reply "I've already put the earmuffs on!"
    end
  end
  
  def listening?
    @listening
  end
  
  # The actual logging
  
  on_event :incoming_message do
    log_message(options.nick, options.target, options.message)
  end
  
  on_event :outgoing_message do
    log_message(client.nickname, options.target, options.message)
  end
  
  on_event :incoming_action do
    log_message(options.nick, options.target, "ACTION #{options.message}")
  end
  
  def log_message(from, to, message)
    return unless listening?
    self.users[from.strip] ||= IrcHandle.find_or_create_by_name(from.strip)
    self.users[from.strip].messages.create :message => message, :target => to
  end
  
  # Our General Tasks
  
  def setup!
    return true if self.setup
    load_prerequisites
    self.setup = true
    self.listening = true
  end
  
  def load_prerequisites
    require File.join(Marvin::Settings.rails_root, "config/environment")
  end
  
  def ensure_connection_is_alive
    unless ActiveRecord::Base.connection.active?
      ActiveRecord::Base.connection.reconnect!
    end
  end
  
  
end