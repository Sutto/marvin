class HelloWorld < Marvin::CommandHandler
  
  exposes :hello
  
  def hello(data)
    reply "Hola from process with pid #{Process.pid}!"
  end
  
end