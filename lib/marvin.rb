$:.unshift File.dirname(__FILE__) # Append the current working dir to the front of the line.

require 'rubygems'
require 'active_support'
require 'marvin/core_ext'

# Make all exceptions available
require 'marvin/exceptions'

module Marvin
  module VERSION
    MAJOR = 0
    MINOR = 3
    PATCH = 0
    
    STRING = [MAJOR, MINOR, PATCH].join(".")
  end
  
  autoload :Util,             'marvin/util'
  autoload :Dispatchable,     'marvin/dispatchable'
  autoload :Distributed,      'marvin/distributed'
  autoload :AbstractClient,   'marvin/abstract_client'
  autoload :Base,             'marvin/base'
  autoload :Console,          'marvin/console'
  autoload :CoreCommands,     'marvin/core_commands'
  autoload :ClientMixin,      'marvin/client_mixin'
  autoload :Settings,         'marvin/settings'
  autoload :Logger,           'marvin/logger'
  autoload :IRC,              'marvin/irc'
  autoload :TestClient,       'marvin/test_client'
  autoload :Loader,           'marvin/loader'
  autoload :MiddleMan,        'marvin/middle_man'
  autoload :DRBHandler,       'marvin/drb_handler'
  autoload :DataStore,        'marvin/data_store'
  autoload :ExceptionTracker, 'marvin/exception_tracker'
  autoload :Options,          'marvin/options'
  autoload :Daemon,           'marvin/daemon'
  autoload :Status,           'marvin/status'
  # Parsers
  autoload :AbstractParser,   'marvin/abstract_parser'
  autoload :Parsers,          'marvin/parsers.rb'
  
  # Default Handlers
  autoload :CommandHandler, 'marvin/command_handler'
  
  Settings.setup # Load Settings etc.
  
  def self.version
    VERSION::STRING
  end
  
end