module Marvin
  module Parsers
    # Default Parsers
    autoload :RegexpParser, 'marvin/parsers/regexp_parser'
    autoload :SimpleParser, 'marvin/parsers/simple_parser'
    autoload :Prefixes,     'marvin/parsers/prefixes'
    autoload :Command,      'marvin/parsers/command'
    autoload :RagelParser,  'marvin/parsers/ragel_parser'
  end
end