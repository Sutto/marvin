require 'marvin'
Marvin::DSL.run do
  
  configure do |c|
    c.real_name = "Marvin Bot of Doom"
    c.user_name = "MarvinBot"
    c.nicks     = "Marvin", "Marvin_", "Marvin__"
  end
  
  logging do
    
    setup do
      @file = File.open(Marvin::Settings.root.join("logs", "irc.log"), "w+")
    end
    
    incoming do |server, nick, target, message|
      @file.puts "<< #{Time.now} <#{target}:#{server}> #{nick}: #{message}"
    end
    
    outgoing do |server, nick, target, message|
      @file.puts ">> #{Time.now} <#{target}:#{server}> #{nick}: #{message}"
    end
    
    teardown do
      @file.close if @file
    end
    
  end
  
  handler do
    
    on :incoming_action do
      reply "Hey! Are we related?" if from.include?(client.nickname)
    end
    
  end
  
  commands do
    
    prefix_is "!"
    
    command :awesome, "Tells you how awesome you are" do
      reply "You are #{25 + rand(75)}% awesome!"
    end
    
  end
  
  server "irc.freenode.net" do
    
    join "#marvin-testing", "#relayrelay"
    
  end
  
end