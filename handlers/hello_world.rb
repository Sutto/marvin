class HelloWorld < Marvin::CommandHandler
  
  exposes :hello
  
  def hello(data)
    reply "Hola!"
  end
  
end