# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{marvin}
  s.version = "0.8.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Darcy Laycock"]
  s.date = %q{2009-09-27}
  s.default_executable = %q{marvin}
  s.description = %q{Marvin is a library (also usable in framework / application form) that
makes it simple and fast to build applications around IRC. With an emphasis
on making common tasks (e.g. replies, bots using method call style syntax
and the like) easy, whilst still making it possible to do more complex thing
(1 connection, N worker processes, Multiple servers, etc) it aims to make
working with IRC in an evented fashion fun and easy for all rubyists.}
  s.email = %q{sutto@sutto.net}
  s.executables = ["marvin"]
  s.files = ["bin/marvin", "lib/marvin", "lib/marvin/abstract_client.rb", "lib/marvin/abstract_parser.rb", "lib/marvin/base.rb", "lib/marvin/client", "lib/marvin/client/actions.rb", "lib/marvin/client/default_handlers.rb", "lib/marvin/command_handler.rb", "lib/marvin/console.rb", "lib/marvin/core_commands.rb", "lib/marvin/distributed", "lib/marvin/distributed/client.rb", "lib/marvin/distributed/handler.rb", "lib/marvin/distributed/protocol.rb", "lib/marvin/distributed/server.rb", "lib/marvin/distributed.rb", "lib/marvin/dsl.rb", "lib/marvin/exception_tracker.rb", "lib/marvin/exceptions.rb", "lib/marvin/irc", "lib/marvin/irc/client.rb", "lib/marvin/irc/event.rb", "lib/marvin/irc/replies.rb", "lib/marvin/irc.rb", "lib/marvin/logging_handler.rb", "lib/marvin/middle_man.rb", "lib/marvin/parsers", "lib/marvin/parsers/command.rb", "lib/marvin/parsers/prefixes", "lib/marvin/parsers/prefixes/host_mask.rb", "lib/marvin/parsers/prefixes/server.rb", "lib/marvin/parsers/prefixes.rb", "lib/marvin/parsers/ragel_parser.rb", "lib/marvin/parsers/ragel_parser.rl", "lib/marvin/parsers/simple_parser.rb", "lib/marvin/parsers.rb", "lib/marvin/settings.rb", "lib/marvin/test_client.rb", "lib/marvin/util.rb", "lib/marvin.rb", "templates/boot.erb", "templates/connections.yml.erb", "templates/debug_handler.erb", "templates/hello_world.erb", "templates/rakefile.erb", "templates/settings.yml.erb", "templates/setup.erb", "templates/test_helper.erb", "test/abstract_client_test.rb", "test/parser_comparison.rb", "test/parser_test.rb", "test/test_helper.rb", "test/util_test.rb", "handlers/debug_handler.rb", "handlers/hello_world.rb", "handlers/keiki_thwopper.rb", "handlers/simple_logger.rb", "handlers/tweet_tweet.rb"]
  s.homepage = %q{http://sutto.net/}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.2}
  s.summary = %q{Evented IRC Library for Ruby, built on EventMachine and Perennial.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<perennial>, [">= 1.0.0.0"])
      s.add_runtime_dependency(%q<eventmachine>, [">= 0.12.8"])
      s.add_runtime_dependency(%q<json>, [">= 0"])
    else
      s.add_dependency(%q<perennial>, [">= 1.0.0.0"])
      s.add_dependency(%q<eventmachine>, [">= 0.12.8"])
      s.add_dependency(%q<json>, [">= 0"])
    end
  else
    s.add_dependency(%q<perennial>, [">= 1.0.0.0"])
    s.add_dependency(%q<eventmachine>, [">= 0.12.8"])
    s.add_dependency(%q<json>, [">= 0"])
  end
end
