module Marvin
  class Base
    include Singleton
    
    attr_accessor :client
    
    def handle_nick_taken(opts = {})
      Marvin::Logger.debug "Your chosen nickname - #{opts[:nick]} - Has been taken. Please change it."
      exit!
    end
    
    def handle_message(opts = {})
      Marvin::Logger.debug("Got Message in #{opts[:target]} - #{opts[:message]}")
      client::say "Hello, #{opts[:nick]}", opts[:target] if opts[:message] =~ /h(ello|i)/i
      client::part opts[:target], "buhbye" if opts[:message] =~ /diediedie/i
    end
    
  end
end