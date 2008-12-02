# Is loaded on setup / when handlers need to be
# registered. Use it to register handlers / do
# any repeatable setup that will happen before
# any connections are created
Marvin::Loader.before_run do
  
  # E.G.
  # MyHandler.register! (Marvin::Base subclass) or
  # Marvin::Settings.default_client.register_handler my_handler (a handler instance)
  
  # Example Handler use.
  # LoggingHandler.register! if Marvin::Settings.use_logging
  
  if Marvin::Loader.type == :client
    Marvin::Distributed::DispatchHandler.register!
  else
    HelloWorld.register!
    DebugHandler.register!
  end
  
end