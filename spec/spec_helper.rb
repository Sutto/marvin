require "rubygems"
require "bacon"

require File.dirname(__FILE__) + "/../lib/marvin"
# Now, Set everything up.
Marvin::Logger.logger = Logger.new(File.dirname(__FILE__) + "/../log/test.log")
Marvin::Settings.default_client = Marvin::TestClient
Marvin::Loader.run!

def client(force_new = false)
  $test_client = Marvin::TestClient.new if force_new || $test_client.nil?
  return $test_client
end

