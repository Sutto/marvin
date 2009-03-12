# Use this class to debug stuff as you 
# go along - e.g. dump events etc.
class DebugHandler < Marvin::CommandHandler
  
  exposes :about
  def about(*args)
    reply "Marvin v#{Marvin::VERSION::STRING} running on Ruby #{RUBY_VERSION} (#{RUBY_PLATFORM})"
  end
    
end