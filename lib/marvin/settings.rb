# Example of extending built in Perennial
# functionality. Since const_get etc acts
# oddly, this is the best way to do it.
Marvin::Settings.class_eval do
  
  def self.parser
    # We use SimpleParser by default because it is almost
    # 20 times faster (from basic benchmarks) than the Ragel
    # based parser. If you're having issues with unexpected
    # results, please try using Ragel as the parser for you
    # application - It was (afaik) almost a direct port
    # from the RFC where as I've taken some liberties with
    # simple parser for the expected reasons.
    @@parser ||= Marvin::Parsers::SimpleParser
  end
  
  def self.parser=(value)
    raise ArgumentError, 'Is not a valid parser implementation' unless value < Marvin::AbstractParser
    @@parser = value
  end
  
  def self.client
    @@client ||= Marvin::IRC::Client
  end
  
  def self.client=(value)
    raise ArgumentError, 'Is not a valid client implementation' unless value < Marvin::AbstractClient
    @@client = value
  end
  
end