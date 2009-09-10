require 'rubygems'

# Testing dependencies
require 'test/unit'
require 'shoulda'
# RedGreen doesn't seem to be needed under 1.9
require 'redgreen' if RUBY_VERSION < "1.9"

require 'pathname'
root_directory = Pathname.new(__FILE__).dirname.join("..").expand_path
require root_directory.join("lib", "marvin")

Marvin::Settings.setup!
Marvin::Logger.setup!

Marvin::Settings.client = Marvin::TestClient

class Test::Unit::TestCase

  @test_client = nil

  protected

  def client(force_new = false)
    @test_client = Marvin::TestClient.new if force_new || @test_client.nil?
    @test_client
  end
  
  # Short hand for creating a class with
  # a given class_eval block.
  def class_via(*args, &blk)
    klass = Class.new(*args)
    klass.class_eval(&blk) unless blk.blank?
    return klass
  end
  
  # Short hand for creating a test class
  # for a set of mixins - give it the modules
  # and it will include them all.
  def test_class_for(*mods, &blk)
    klass = Class.new
    klass.class_eval { include(*mods) }
    klass.class_eval(&blk) unless blk.blank?
    return klass
  end
  
  def assert_dispatched(name, position = -1)
    assert_equal name, client.dispatched_events[position].first
  end
  
  def assert_sent_line(line, position = -1)
    assert_equal line, client.outgoing_commands[position]
  end
  
  def assert_resets_client
    assert_equal [], client(true).dispatched_events
  end
  
end
