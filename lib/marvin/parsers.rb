module Marvin
  module Parsers
    # Default Parsers
    autoload :Prefixes,     'marvin/parsers/prefixes'
    autoload :Command,      'marvin/parsers/command'
    autoload :SimpleParser, 'marvin/parsers/simple_parser'
    autoload :RagelParser,  'marvin/parsers/ragel_parser'
  end
end