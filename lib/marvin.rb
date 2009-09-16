$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rubygems'
require 'perennial'

module Marvin
  include Perennial
  
  VERSION = [0, 8, 0, 0]
  
  # Misc.
  #autoload :Util,             'marvin/util'
  # Client
  #autoload :AbstractClient,   'marvin/abstract_client'
  #autoload :IRC,              'marvin/irc'
  autoload :TestClient,       'marvin/test_client'
  # Console of DOOM.
  autoload :Console,          'marvin/console'
  # Distributed
  autoload :Distributed,      'marvin/distributed'
  autoload :Status,           'marvin/status'
  # Handler
  autoload :Base,             'marvin/base'
  autoload :CommandHandler,   'marvin/command_handler'
  autoload :LoggingHandler,   'marvin/logging_handler'
  autoload :CoreCommands,     'marvin/core_commands'
  autoload :MiddleMan,        'marvin/middle_man'
  # These should be namespaced under IRC
  #autoload :AbstractParser,   'marvin/abstract_parser'
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
  
  def self.version(include_minor = false)
    VERSION[0, (include_minor ? 4 : 3)].join(".")
  end
  
  has_library :util, :abstract_client, :abstract_parser, :irc, :exception_tracker
  
  extends_library :settings
  
end