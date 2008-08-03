# Register all of the handlers you wish to use
# when the clien connects.
Marvin::Loader.before_connecting do
  
  # E.G.
  # MyHandler.register! (Marvin::Base subclass)
  # or
  # Marvin::Settings.default_client.register_handler my_handler
  
end