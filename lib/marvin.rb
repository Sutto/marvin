$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rubygems'
require 'perennial'

module Marvin
  include Perennial
  
  VERSION = "0.5.0"
  
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
    Settings.root = File.dirname(__FILE__)
    l.register_controller :client,  'Marvin::IRC::Client'
    l.register_controller :console, 'Marvin::Console'
    # Core Commands handily makes available a set
    # of information about what is running etc.
    l.before_run { Marvin::CoreCommands.register! if Marvin::Loader.client? }
  end
  
  has_library :util, :abstract_client, :abstract_parser, :irc
  
end