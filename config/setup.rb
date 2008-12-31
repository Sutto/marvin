# Is loaded on setup / when handlers need to be
# registered. Use it to register handlers / do
# any repeatable setup that will happen before
# any connections are created
Marvin::Loader.before_run do
  
  # Want a non-default namespace? Choose something simple
  # Marvin::Settings.distributed_namespace = :some_namespace
  
  # E.G.
  # MyHandler.register! (Marvin::Base subclass) or
  # Marvin::Settings.default_client.register_handler my_handler (a handler instance)
  
  # Register in ruby
  #
  # LoggingHandler.register! if Marvin::Settings.use_logging
  
  # Conditional registration - load the distributed dispatcher
  # if an actual client, otherwise use the normal handlers.
  #
  # if Marvin::Loader.distributed_client?
  #   HelloWorld.register!
  #   DebugHandler.register!
  # else
  #   Marvin::Distributed::DispatchHandler.register!
  # end
  
  # And any other code here that will be run before the client
  
  #HelloWorld.register!
  #DebugHandler.register!
  
  if Marvin::Loader.server?
   rails_dir = "/Users/sutto/Code/RelayRelay/PowWow"
   ENV['RAILS_ENV'] ||= "development"
   require File.join(rails_dir, 'config/environment')
   require File.join(rails_dir, 'lib/marvin_event_processor')
   # Register our super-dooper processer thingy
   Marvin::IRC::Server::UserConnection.register_handler MarvinEventProcessor.new
  end
  
end