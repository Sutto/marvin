require File.join(File.dirname(__FILE__), 'test_helper')

class UtilTest < Test::Unit::TestCase
  
  context "Converting a string to a channel name" do
    
    should "not convert it if it starts with #" do
      assert_equal "#offrails", Marvin::Util.channel_name("#offrails")
    end
    
    should "append a # if not present" do
      assert_equal "#offrails", Marvin::Util.channel_name("offrails")
    end
    
    should "also be available as chan" do
      assert_equal "#offrails", Marvin::Util.chan("#offrails")
      assert_equal "#offrails", Marvin::Util.chan("offrails")
    end
    
  end
  
  context "Parsing arguments" do
    
    should "parse 'a b c' as ['a', 'b', 'c']" do
      assert_equal ['a', 'b', 'c'], Marvin::Util.arguments("a b c")
    end
    
    should "parse 'a b :c d' as ['a', 'b', 'c d']" do
      assert_equal ['a', 'b', 'c d'], Marvin::Util.arguments("a b :c d")
    end
    
    should "parse 'a :b c :d e' as ['a', 'b c :d e']" do
      assert_equal ['a', 'b c :d e'], Marvin::Util.arguments('a :b c :d e')
    end
    
  end
  
  context "Preparing last parameters" do
    
    should "prepend a :" do
      assert_equal ':zomg ninjas',  Marvin::Util.last_param('zomg ninjas')
      assert_equal '::zomg ninjas', Marvin::Util.last_param(':zomg ninjas')
    end
    
    should "strip the input" do
      assert_equal ':zomg ninjas', Marvin::Util.last_param('   zomg ninjas ')
    end
    
    should "be available as lp" do
      assert_equal ':zomg ninjas',  Marvin::Util.lp('zomg ninjas')
      assert_equal '::zomg ninjas', Marvin::Util.lp(':zomg ninjas')
      assert_equal ':zomg ninjas',  Marvin::Util.lp('   zomg ninjas ')
    end
    
  end
  
end