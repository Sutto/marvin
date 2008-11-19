# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{marvin}
  s.version = "0.1.20081120"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Darcy Laycock"]
  s.date = %q{2008-11-20}
  s.default_executable = %q{marvin}
  s.description = %q{Marvin is a Ruby IRC library / framework for ultimate awesomeness and with an evented design.}
  s.email = %q{sutto@sutto.net}
  s.executables = ["marvin"]
  s.files = ["README.textile", "VERSION.yml", "bin/marvin", "lib/marvin", "lib/marvin/abstract_client.rb", "lib/marvin/abstract_parser.rb", "lib/marvin/base.rb", "lib/marvin/command_handler.rb", "lib/marvin/core_ext.rb", "lib/marvin/data_store.rb", "lib/marvin/dispatchable.rb", "lib/marvin/drb_handler.rb", "lib/marvin/exception_tracker.rb", "lib/marvin/exceptions.rb", "lib/marvin/handler.rb", "lib/marvin/irc", "lib/marvin/irc/abstract_server.rb", "lib/marvin/irc/base_server.rb", "lib/marvin/irc/client.rb", "lib/marvin/irc/event.rb", "lib/marvin/irc/replies.rb", "lib/marvin/irc.rb", "lib/marvin/loader.rb", "lib/marvin/logger.rb", "lib/marvin/middle_man.rb", "lib/marvin/options.rb", "lib/marvin/parsers", "lib/marvin/parsers/regexp_parser.rb", "lib/marvin/parsers/simple_parser", "lib/marvin/parsers/simple_parser/default_events.rb", "lib/marvin/parsers/simple_parser/event_extensions.rb", "lib/marvin/parsers/simple_parser/prefixes.rb", "lib/marvin/parsers/simple_parser.rb", "lib/marvin/parsers.rb", "lib/marvin/settings.rb", "lib/marvin/test_client.rb", "lib/marvin/util.rb", "lib/marvin.rb", "test/parser_test.rb", "test/test_helper.rb", "spec/marvin", "spec/marvin/abstract_client_test.rb", "spec/spec_helper.rb", "script/client", "script/daemon-runner", "script/install", "handlers/hello_world.rb", "handlers/logging_handler.rb", "handlers/tweet_tweet.rb", "config/setup.rb", "config/settings.yml.sample", "config/connections.yml.sample"]
  s.homepage = %q{http://blog.ninjahideout.com/}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Ruby IRC Library / Framework}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
