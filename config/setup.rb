# Register all of the handlers you wish to use
# when the clien connects.
Marvin::Loader.before_connecting do
  
  LoggingHandler.register! if Marvin::Settings.use_logging
  KnowledgeHandler.register!
  
end