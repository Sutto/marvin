class HelloWorld < Marvin::CommandHandler
  
  exposes :hello
  
  uses_datastore "hello-count", :counts
  
  
  def hello(data)
    self.counts[options.nick] ||= 0
    self.counts[options.nick] += 1
    reply "Oh hai there - This is hello ##{self.counts[options.nick]} from you!"
  end
  
end