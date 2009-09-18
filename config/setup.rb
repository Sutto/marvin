# Is loaded on setup / when handlers need to be
# registered. Use it to register handlers / do
# any repeatable setup that will happen before
# any connections are created
Marvin::Loader.before_run do
  
  # E.G.
  # MyHandler.register! (Marvin::Base subclass) or
  # Marvin::Settings.client.register_handler my_handler (a handler instance)
  
  # Register based on some setting you've added. e.g.:
  # LoggingHandler.register! if Marvin::Settings.use_logging?
  
  # Conditional registration - load the distributed dispatcher
  # if an actual client, otherwise use the normal handlers.
  #
  if Marvin::Loader.distributed_client?
    HelloWorld.register!
    DebugHandler.register!
  else
    Marvin::Distributed::Handler.register!
  end
  
  # end
  
  # And any other code here that will be run before the client, e.g:
  
  # HelloWorld.register!
  # DebugHandler.register!
  
end