$:.unshift File.dirname(__FILE__) # Append the current working dir to the front of the line.

require 'rubygems'
require 'active_support'
require 'marvin/core_ext'

module Marvin
  autoload :Base,     'marvin/base'
  autoload :Settings, 'marvin/settings'
  autoload :Logger,   'marvin/logger'
  autoload :IRC,      'marvin/irc'
  
  Settings.setup # Load Settings etc.
  
end