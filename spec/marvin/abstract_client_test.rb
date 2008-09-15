require File.dirname(__FILE__) + "/../spec_helper"

# Tests the behaviour of the AbstractClient functionality
# via a thin wrapper of the class via Marvin::TestClient.

describe "the base Marvin::TestClient functionality" do
  
  it "should dispatch :client_connected as the first event on process_connect" do
    client(true).dispatched_events.should == []
    client.process_connect
    client.dispatched_events.first.should == [:client_connected, {}]
  end
  
  it "should dispatch :client_connected as the first event on process_connect" do
    client(true).dispatched_events.should == []
    client.process_connect
    Marvin::Logger.info client.outgoing_commands.inspect
    client.dispatched_events[-2].first.should == :outgoing_nick
    client.dispatched_events[-1].first.should == :outgoing_join
    client.outgoing_commands.length.should == 3
    client.outgoing_commands[0].should =~ /^USER \w+ 0 \* :\w+ \r\n$/
    client.outgoing_commands[1].should =~ /^NICK \w+ \r\n$/
    client.outgoing_commands[2].should =~ /^JOIN \#[A-Za-z0-9\-\_]+ \r\n$/
  end
  
  it "should dispatch :client_disconnect on process_disconnect" do
    client(true).dispatched_events.should == []
    client.process_disconnect
    client.dispatched_events.last.should == [:client_disconnected, {}]
  end
  
  it "should add an :incoming_line event for each incoming line" do
    client(true).dispatched_events.should == []
    client.receive_line "SOME RANDOM LINE THAT HAS ZERO ACTUAL USE"
    client.dispatched_events.first.should == [:incoming_line, {:line => "SOME RANDOM LINE THAT HAS ZERO ACTUAL USE"}]
  end
  
end