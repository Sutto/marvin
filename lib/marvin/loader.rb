require 'fileutils'
require 'singleton'

module Marvin
  class Loader
    include Singleton
    
    # A Controller is any class e.g. a client / server
    # which is provides the main functionality of the
    # current client.
    CONTROLLERS = {
      :client             => Marvin::Settings.default_client,
      :server             => Marvin::IRC::Server,
      :ring_server        => Marvin::Distributed::RingServer,
      :distributed_client => Marvin::Distributed::DRbClient
    }
    
    
    cattr_accessor :hooks, :boot, :type
    self.hooks = {}
    self.type = :client
    
    # Old style of registering a block to be run on startup
    # for doing setup etc. now replaced by before_run
    def self.before_connecting(&blk)
      Marvin::Logger.warn "Marvin::Loader.before_connecting is deprecated, please use before_run instead."
      before_run(&blk)
    end
    
    def self.append_hook(type, &blk)
      self.hooks_for(type) << blk unless blk.blank?
    end
    
    def self.hooks_for(type)
      (self.hooks[type.to_sym] ||= [])
    end
    
    def self.invoke_hooks!(type)
      hooks_for(type).each { |hook| hook.call }
    end
    
    # Append a call back to be run at a specific stage.
    
    # Register a hook to be run before the controller
    # has started running.
    def self.before_run(&blk)
      append_hook(:before_run, &blk)
    end
    
    # Register a hook to be run after the controller
    # has stopped. Note that this will not guarantee
    # all processing has completed.
    def self.after_stop(&blk)
      append_hook(:after_stop, &blk)
    end
    
    def self.run!(type = :client)
      self.type = type.to_sym
      self.instance.run!
    end
    
    def self.stop!(force = false)
      self.instance.stop!(force)
    end
    
    def run!
      Marvin::Options.parse! unless self.type == :console
      Marvin::Logger.setup
      self.load_settings
      require(Marvin::Settings.root / "config/setup")
      self.load_handlers
      self.class.invoke_hooks!   :before_run
      attempt_controller_action! :run
    end
    
    def stop!(force = false)
      if force || !@attempted_stop
        self.class.invoke_hooks!   :before_stop
        attempt_controller_action! :stop
        self.class.invoke_hooks!   :after_stop
        @attempted_stop = true
      end
    end
    
    protected
    
    # Get the controller for the current type if
    # it exists and attempt to class a given action.
    def attempt_controller_action!(action)
      klass = CONTROLLERS[self.type]
      klass.send(action) unless klass.blank? || !klass.respond_to?(action, true)
    end
    
    # Load all of the handler's in the handlers subfolder
    # of a marvin installation.
    def load_handlers
      Dir[Marvin::Settings.root / "handlers/**/*.rb"].each { |handler| require handler }
    end
    
    def load_settings
      Marvin::Settings.setup
      case Marvin::Loader.type
      # Perform client / type specific setup.
      when :client
        Marvin::Settings.default_client.configuration = Marvin::Settings.to_hash
        Marvin::Settings.default_client.setup
      when :distributed_client
        Marvin::Settings.default_client = Marvin::Distributed::DRbClient
      end
    end
    
    # Register to the Marvin::DataStore methods
    before_run { Marvin::DataStore.load! if Marvin::Loader.type == :client }
    after_stop { Marvin::DataStore.dump! if Marvin::Loader.type == :client }
    
  end
end