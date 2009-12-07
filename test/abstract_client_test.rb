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
      assert_resets_client
      client.process_connect
      assert_equal [:client_connected, {}], client.dispatched_events.first
      assert_dispatched :client_connected, 0, {}
    end

    should "dispatch the correct events" do
      assert_resets_client
      client.default_channels = ["#awesome", "#rock"]
      client.process_connect
      assert_dispatched :client_connected, -2, {}
      assert_dispatched :outgoing_nick,    -1
      assert_equal 2, client.outgoing_commands.length
      assert_equal "NICK Haysoos\r\n", client.outgoing_commands[0]
      assert_sent_line "NICK Haysoos\r\n", 0
      assert_sent_line "USER DemoUser 0 \* :Demo Users Name\r\n", 1
    end

    should "dispatch :client_disconnect on process_disconnect" do
      assert_resets_client
      client.process_disconnect
      assert_dispatched :client_disconnected
    end
    
    should 'attempt to join the default channels on receiving welcome' do
      assert_resets_client
      client.default_channels = ["#awesome", "#rock"]
      client.handle_welcome
      assert_sent_line "JOIN #awesome,#rock\r\n"
    end

    should "add an :incoming_line event for each incoming line" do
      assert_resets_client
      client.receive_line "SOME RANDOM LINE THAT HAS ZERO ACTUAL USE"
      assert_dispatched :incoming_line, 0, :line => "SOME RANDOM LINE THAT HAS ZERO ACTUAL USE"
    end
    
    teardown do
      @client.configuration = @config
    end
    
  end
  
end