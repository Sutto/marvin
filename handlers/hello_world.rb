class HelloWorld < Marvin::CommandHandler
  
  exposes :hello
  
  on_event :incoming_message do
    STDOUT.puts "ZOMBIE JESUS OMG!"
  end
  
  def hello(data)
    reply "Oh hai there"
  end
  
end