require File.join(File.dirname(__FILE__), 'test_helper')

# In reality this tests several different classes:
# 1) The parser itself
# 2) The Command class
# 3) The two different types of prefixes
# 4) The Event class
class ParserTest < Test::Unit::TestCase
  
  # The default parser
  @@parser = Marvin::Parsers::SimpleParser
  
  context "When parsing a LIST" do
    setup { @parsed = @@parser.new("LIST #twilight_zone,#42") }
    
    should "not be nil" do
      assert !@parsed.nil?
    end
    
    should "have a command" do
      assert !@parsed.command.nil?
    end
    
    should "have not a prefix" do
      assert @parsed.command.prefix.nil?
    end
    
    should "have a code of LIST" do
      assert_equal "LIST", @parsed.command.code
    end
    
    should "have the correct arguments" do
      assert_equal ["#twilight_zone,#42"], @parsed.command.params
    end
    
    should "be able to convert to an event" do
      assert !@parsed.to_event.nil?
    end
    
    should "have the correct incoming event name" do
      assert_equal :incoming_list, @parsed.to_event.to_incoming_event_name
    end
    
    should "have the correct outgoing event name" do
      assert_equal :outgoing_list, @parsed.to_event.to_outgoing_event_name
    end
    
    should "convert to the correct hash" do
      assert_equal({:channel => "#twilight_zone,#42", :target => ""}, @parsed.to_event.to_hash)
    end
    
  end
  
  context "When parsing a JOIN" do
    setup { @parsed = @@parser.new(":RelayBot!n=MarvinBot@static.amnet.net.au JOIN :#relayrelay") }
    
    should "not be nil" do
      assert !@parsed.nil?
    end
    
    should "have a command" do
      assert !@parsed.command.nil?
    end
    
    should "have a prefix" do
      assert !@parsed.command.prefix.nil?
    end
    
    should "have a code of JOIN" do
      assert_equal "JOIN", @parsed.command.code
    end
    
    should "have the correct arguments" do
      assert_equal ["#relayrelay"], @parsed.command.params
    end
    
    should "have a host mask" do
      assert @parsed.command.prefix.is_a?(Marvin::Parsers::Prefixes::HostMask)
    end
    
    should "have the correct nick" do
      assert_equal "RelayBot", @parsed.command.prefix.nick
    end
    
    should "have the correct user" do
      assert_equal "n=MarvinBot", @parsed.command.prefix.user
    end
    
    should "have the correct host" do
      assert_equal "static.amnet.net.au", @parsed.command.prefix.host
    end
    
    should "be able to convert to an event" do
      assert !@parsed.to_event.nil?
    end
    
    should "have the correct incoming event name" do
      assert_equal :incoming_join, @parsed.to_event.to_incoming_event_name
    end
    
    should "have the correct outgoing event name" do
      assert_equal :outgoing_join, @parsed.to_event.to_outgoing_event_name
    end
    
    should "convert to the correct hash" do
      assert_equal({:target => "#relayrelay", :key => ""}.merge(@parsed.command.prefix.to_hash), @parsed.to_event.to_hash)
    end
    
  end
  
  context "When parsing a PRIVMSG" do
    setup { @parsed = @@parser.new(":SuttoL!n=SuttoL@sutto.net PRIVMSG #relayrelay :testing...") }
    
    should "not be nil" do
      assert !@parsed.nil?
    end
    
    should "have a command" do
      assert !@parsed.command.nil?
    end
    
    should "have a prefix" do
      assert !@parsed.command.prefix.nil?
    end
    
    should "have a code of PRIVMSG" do
      assert_equal "PRIVMSG", @parsed.command.code
    end
    
    should "have the correct arguments" do
      assert_equal ["#relayrelay", "testing..."], @parsed.command.params
    end
    
    should "have a host mask" do
      assert @parsed.command.prefix.is_a?(Marvin::Parsers::Prefixes::HostMask)
    end
    
    should "have the correct nick" do
      assert_equal "SuttoL", @parsed.command.prefix.nick
    end
    
    should "have the correct user" do
      assert_equal "n=SuttoL", @parsed.command.prefix.user
    end
    
    should "have the correct host" do
      assert_equal "sutto.net", @parsed.command.prefix.host
    end
    
    should "be able to convert to an event" do
      assert !@parsed.to_event.nil?
    end
    
    should "have the correct incoming event name" do
      assert_equal :incoming_message, @parsed.to_event.to_incoming_event_name
    end
    
    should "have the correct outgoing event name" do
      assert_equal :outgoing_message, @parsed.to_event.to_outgoing_event_name
    end
    
    should "convert to the correct hash" do
      assert_equal({:target => "#relayrelay", :message => "testing..."}.merge(@parsed.command.prefix.to_hash), @parsed.to_event.to_hash)
    end
    
  end
  
  context "When parsing a numeric - 366" do
    setup { @parsed = @@parser.new(":irc.darth.vpn.spork.in 366 testbot #testing :End of NAMES list") }
    
    should "not be nil" do
      assert !@parsed.nil?
    end
    
    should "have a command" do
      assert !@parsed.command.nil?
    end
    
    should "have a prefix" do
      assert !@parsed.command.prefix.nil?
    end
    
    should "have a code of 366" do
      assert_equal "366", @parsed.command.code
    end
    
    should "have the correct arguments" do
      assert_equal ["testbot", "#testing", "End of NAMES list"], @parsed.command.params
    end
    
    should "have a host mask" do
      assert @parsed.command.prefix.is_a?(Marvin::Parsers::Prefixes::Server)
    end
    
    should "have the correct name" do
      assert_equal "irc.darth.vpn.spork.in", @parsed.command.prefix.name
    end
    
    should "be able to convert to an event" do
      assert !@parsed.to_event.nil?
    end
    
    should "have the correct incoming event name" do
      assert_equal :incoming_numeric, @parsed.to_event.to_incoming_event_name
    end
    
    should "have the correct outgoing event name" do
      assert_equal :outgoing_numeric, @parsed.to_event.to_outgoing_event_name
    end
    
    should "convert to the correct hash" do
      assert_equal({:code => "366", :data => "testbot #testing :End of NAMES list"}.merge(@parsed.command.prefix.to_hash), @parsed.to_event.to_hash)
    end
    
  end
  
  context "When parsing a numeric - 004" do
    setup { @parsed = @@parser.new(":wolfe.freenode.net 004 MarvinBot3000 wolfe.freenode.net hyperion-1.0.2b aAbBcCdDeEfFGhHiIjkKlLmMnNopPQrRsStTuUvVwWxXyYzZ01234569*@ bcdefFhiIklmnoPqstv") }
    
    should "not be nil" do
      assert !@parsed.nil?
    end
    
    should "have a command" do
      assert !@parsed.command.nil?
    end
    
    should "have a prefix" do
      assert !@parsed.command.prefix.nil?
    end
    
    should "have a code of 366" do
      assert_equal "004", @parsed.command.code
    end
    
    should "have the correct arguments" do
      assert_equal ["MarvinBot3000" , "wolfe.freenode.net", "hyperion-1.0.2b", "aAbBcCdDeEfFGhHiIjkKlLmMnNopPQrRsStTuUvVwWxXyYzZ01234569*@", "bcdefFhiIklmnoPqstv"], @parsed.command.params
    end
    
    should "have a host mask" do
      assert @parsed.command.prefix.is_a?(Marvin::Parsers::Prefixes::Server)
    end
    
    should "have the correct name" do
      assert_equal "wolfe.freenode.net", @parsed.command.prefix.name
    end
    
    should "be able to convert to an event" do
      assert !@parsed.to_event.nil?
    end
    
    should "have the correct incoming event name" do
      assert_equal :incoming_numeric, @parsed.to_event.to_incoming_event_name
    end
    
    should "have the correct outgoing event name" do
      assert_equal :outgoing_numeric, @parsed.to_event.to_outgoing_event_name
    end
    
    should "convert to the correct hash" do
      assert_equal({:code => "004", :data => "MarvinBot3000 wolfe.freenode.net hyperion-1.0.2b aAbBcCdDeEfFGhHiIjkKlLmMnNopPQrRsStTuUvVwWxXyYzZ01234569*@ bcdefFhiIklmnoPqstv"}.merge(@parsed.command.prefix.to_hash), @parsed.to_event.to_hash)
    end
    
  end
  
end