require File.join(File.dirname(__FILE__), 'test_helper')

class AbstractClientTest < Test::Unit::TestCase
  
  context 'testing out a connection' do

    setup do
      @client = Marvin::Settings.client
      @client.setup
      @config = @client.configuration
      @client.configuration = {
        :user  => "DemoUser",
        :name  => "Demo Users Name",
        :nick  => "Haysoos",
        :nicks => ["Haysoos_", "Haysoos__"]
      }
    end
    
    should "dispatch :client_connected as the first event on process_connect" do
      assert_equal [], client(true).dispatched_events
      client.process_connect
      assert_equal [:client_connected, {}], client.dispatched_events.first
    end

    should "dispatch :client_connected as the first event on process_connect" do
      assert_equal [], client(true).dispatched_events
      client.default_channels = ["#awesome", "#rock"]
      client.process_connect
      assert_equal :client_connected,  client.dispatched_events[-2].first
      assert_equal :outgoing_nick,     client.dispatched_events[-1].first
      assert_equal 2,                  client.outgoing_commands.length
      assert_equal "NICK Haysoos\r\n", client.outgoing_commands[0]
      assert_equal "USER DemoUser 0 \* :Demo Users Name\r\n", client.outgoing_commands[1]
    end

    should "dispatch :client_disconnect on process_disconnect" do
      assert_equal [], client(true).dispatched_events
      client.process_disconnect
      
    end
    
    should 'attempt to join the default channels on receiving welcome' do
      assert_equal [], client(true).dispatched_events
      client.default_channels = ["#awesome", "#rock"]
      client.handle_welcome
      assert_equal "JOIN #awesome,#rock\r\n", client.outgoing_commands[0]
    end

    should "add an :incoming_line event for each incoming line" do
      assert_equal [], client(true).dispatched_events
      client.receive_line "SOME RANDOM LINE THAT HAS ZERO ACTUAL USE"
      assert_equal [:incoming_line, {:line => "SOME RANDOM LINE THAT HAS ZERO ACTUAL USE"}], client.dispatched_events.first
    end
    
    teardown do
      @client.configuration = @config
    end
    
  end
  
end