$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rubygems'
require 'perennial'

module Marvin
  include Perennial
  
  VERSION = [0, 8, 2, 0]
  
  # Client
  autoload :TestClient,       'marvin/test_client'
  # Console of DOOM.
  autoload :Console,          'marvin/console'
  # Distributed
  autoload :Distributed,      'marvin/distributed'
  # Handler
  autoload :Base,             'marvin/base'
  autoload :CommandHandler,   'marvin/command_handler'
  autoload :LoggingHandler,   'marvin/logging_handler'
  autoload :CoreCommands,     'marvin/core_commands'
  autoload :MiddleMan,        'marvin/middle_man'
  # These should be namespaced under IRC
  autoload :Parsers,          'marvin/parsers'
  
  
  manifest do |m, l|
    Settings.root = File.dirname(File.dirname(__FILE__))
    l.register_controller :client,             'Marvin::Settings.client'
    l.register_controller :console,            'Marvin::Console'
    l.register_controller :distributed_client, 'Marvin::Distributed::Client'
    # Core Commands handily makes available a set
    # of information about what is running etc.
    
    l.before_run do
      if l.distributed_client?
        Marvin::Settings.client = Marvin::Distributed::Client 
      end
    end
    
  end
  
  # Returns a string of the current version,
  # optionally including a build number.
  # @param [Boolean] include_build include a build version in the string
  def self.version(include_build = nil)
    include_build = VERSION[3].to_i > 0 if include_build.nil?
    VERSION[0, (include_build ? 4 : 3)].join(".")
  end
  
  has_library :util, :abstract_client, :abstract_parser, :irc, :exception_tracker
  
  extends_library :settings
  
end