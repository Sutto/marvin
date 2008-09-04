# Register all of the handlers you wish to use
# when the clien connects.
Marvin::Loader.before_connecting do
  
  # E.G.
  # MyHandler.register! (Marvin::Base subclass) or
  # Marvin::Settings.default_client.register_handler my_handler (a handler instance)
  
  # Example Handler use.
  # LoggingHandler.register! if Marvin::Settings.use_logging
  
  # Register using Marvin::MiddleMan.
  HelloWorld.register!(Marvin::MiddleMan)
  
end