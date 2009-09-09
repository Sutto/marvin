$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rubygems'
require 'perennial'

module Marvin
  include Perennial
  
  VERSION = "0.5.0"
   
  autoload :Util,             'marvin/util'
  autoload :Distributed,      'marvin/distributed'
  autoload :AbstractClient,   'marvin/abstract_client'
  autoload :Base,             'marvin/base'
  autoload :Console,          'marvin/console'
  autoload :CoreCommands,     'marvin/core_commands'
  autoload :ClientMixin,      'marvin/client_mixin'
  autoload :LoggingHandler,   'marvin/logging_handler'
  autoload :IRC,              'marvin/irc'
  autoload :TestClient,       'marvin/test_client'
  autoload :MiddleMan,        'marvin/middle_man'
  autoload :DRBHandler,       'marvin/drb_handler'
  autoload :Status,           'marvin/status'
  
  autoload :AbstractParser,   'marvin/abstract_parser'
  autoload :Parsers,          'marvin/parsers'
  autoload :CommandHandler,   'marvin/command_handler'
  
  manifest do |m, l|
    Settings.root = File.dirname(__FILE__)
    l.register_controller :client, Marvin::IRC::Client
  end
  
end