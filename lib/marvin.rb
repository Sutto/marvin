$:.unshift File.dirname(__FILE__) # Append the current working dir to the front of the line.

require 'rubygems'
require 'active_support'
require 'marvin/core_ext'

# Make all exceptions available
require 'marvin/exceptions'

module Marvin
  autoload :Util,             'marvin/util'
  autoload :AbstractClient,   'marvin/abstract_client'
  autoload :Base,             'marvin/base'
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
  # Parsers
  autoload :AbstractParser,   'marvin/abstract_parser'
  autoload :Parsers,          'marvin/parsers.rb'
  
  # Default Handlers
  autoload :CommandHandler, 'marvin/command_handler'
  
  Settings.setup # Load Settings etc.
  
end

def p(text)
  res = Marvin::Parsers::SimpleParser.parse(text)
  if res.blank?
    puts "Unrecognized Result"
  else
    STDOUT.puts "Event: #{res.to_incoming_event_name}"
    STDOUT.puts "Args:  #{res.to_hash.inspect}"
  end
end