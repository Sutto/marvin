class HelloWorld < Marvin::CommandHandler
  
  exposes :hello
  
  def hello(data)
    reply "Hola!" unless target == "#all"
  end
  
end