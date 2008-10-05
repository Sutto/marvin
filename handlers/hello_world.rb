class HelloWorld < Marvin::CommandHandler
  
  exposes :hello
  
  uses_datastore "hello-count", :counts
  
  on_event :incoming_numeric_processed do
    logger.info "Incoming: #{options.code} - #{options.data.inspect}"
  end
  
  def hello(data)
    self.counts ||= {}
    self.counts[options.nick] ||= 0
    self.counts[options.nick] += 1
    reply "Oh hai there - This is hello ##{self.counts[options.nick]} from you!"
  end
  
end