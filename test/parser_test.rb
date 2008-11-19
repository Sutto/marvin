class ParserTest < Test::Unit::TestCase
  @@parser = nil
  def self.parser_is(p)
    @@parser = p
  end
  
  context "When parsing a PONG" do
  end
  
  context "When parsing a PING" do
  end
  
  context "When parsing a PRIVMSG" do
  end
  
end

["Regexp", "Simple"].each do |parser_name|
  eval("class #{parser_name}ParserTest < ParserTest; parser_is #{parser_is}Parser; end")
end