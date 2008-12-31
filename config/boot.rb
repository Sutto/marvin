# Load Marvin, do any initialization etc.
# Note: this is called from inside scripts
# or anywhere you want to start a base marvin
# instance.

require 'rubygems'

MARVIN_ROOT = File.expand_path(File.join(File.dirname(__FILE__), ".."))

# Check if a local copy of marvin exists, and set the load path if it does.
$:.unshift(File.dirname(__FILE__) + "/../lib/") if File.exist?(File.dirname(__FILE__) + "/../lib/marvin.rb")

# And Require Marvin.
require 'marvin'