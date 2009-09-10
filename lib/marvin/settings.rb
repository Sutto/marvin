# Example of extending built in Perennial
# functionality. Since const_get etc acts
# oddly, this is the best way to do it.
Marvin::Settings.class_eval do
  
  cattr_writer :parser, :client
  
  def self.parser
    @@parser ||= Marvin::Parsers::RagelParser
  end
  
  def self.client
    @@client ||= Marvin::IRC::Client
  end
  
end