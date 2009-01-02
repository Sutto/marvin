# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{marvin}
  s.version = "0.2.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Darcy Laycock"]
  s.date = %q{2009-01-03}
  s.default_executable = %q{marvin}
  s.description = %q{Marvin is a Ruby IRC library / framework for ultimate awesomeness and with an evented design.}
  s.email = %q{sutto@sutto.net}
  s.executables = ["marvin"]
  s.files = ["README.textile", "TUTORIAL.textile", "VERSION.yml", "bin/marvin", "lib/marvin", "lib/marvin/abstract_client.rb", "lib/marvin/abstract_parser.rb", "lib/marvin/base.rb", "lib/marvin/command_handler.rb", "lib/marvin/console.rb", "lib/marvin/core_ext.rb", "lib/marvin/daemon.rb", "lib/marvin/data_store.rb", "lib/marvin/dispatchable.rb", "lib/marvin/distributed", "lib/marvin/distributed/dispatch_handler.rb", "lib/marvin/distributed/drb_client.rb", "lib/marvin/distributed/ring_server.rb", "lib/marvin/distributed.rb", "lib/marvin/exception_tracker.rb", "lib/marvin/exceptions.rb", "lib/marvin/handler.rb", "lib/marvin/irc", "lib/marvin/irc/client.rb", "lib/marvin/irc/event.rb", "lib/marvin/irc/replies.rb", "lib/marvin/irc/server", "lib/marvin/irc/server/abstract_connection.rb", "lib/marvin/irc/server/base_connection.rb", "lib/marvin/irc/server/channel.rb", "lib/marvin/irc/server/named_store.rb", "lib/marvin/irc/server/remote_interface.rb", "lib/marvin/irc/server/user", "lib/marvin/irc/server/user/handle_mixin.rb", "lib/marvin/irc/server/user.rb", "lib/marvin/irc/server/user_connection.rb", "lib/marvin/irc/server/virtual_user_connection.rb", "lib/marvin/irc/server.rb", "lib/marvin/irc.rb", "lib/marvin/loader.rb", "lib/marvin/logger.rb", "lib/marvin/middle_man.rb", "lib/marvin/options.rb", "lib/marvin/parsers", "lib/marvin/parsers/command.rb", "lib/marvin/parsers/prefixes", "lib/marvin/parsers/prefixes/host_mask.rb", "lib/marvin/parsers/prefixes/server.rb", "lib/marvin/parsers/prefixes.rb", "lib/marvin/parsers/ragel_parser.rb", "lib/marvin/parsers/ragel_parser.rl", "lib/marvin/parsers/regexp_parser.rb", "lib/marvin/parsers/simple_parser.rb", "lib/marvin/parsers.rb", "lib/marvin/settings.rb", "lib/marvin/status.rb", "lib/marvin/test_client.rb", "lib/marvin/util.rb", "lib/marvin.rb", "test/parser_comparison.rb", "test/parser_test.rb", "test/test_helper.rb", "test/util_test.rb", "spec/marvin", "spec/marvin/abstract_client_test.rb", "spec/spec_helper.rb", "script/client", "script/console", "script/distributed_client", "script/install", "script/ring_server", "script/server", "script/status", "handlers/debug_handler.rb", "handlers/hello_world.rb", "handlers/logging_handler.rb", "handlers/tweet_tweet.rb", "config/setup.rb", "config/boot.rb", "config/settings.yml.sample", "config/connections.yml.sample"]
  s.homepage = %q{http://blog.ninjahideout.com/}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Ruby IRC Library / Framework}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<json>, [">= 0"])
      s.add_runtime_dependency(%q<activesupport>, [">= 2.1.0"])
      s.add_runtime_dependency(%q<eventmachine>, [">= 0.12.0"])
      s.add_runtime_dependency(%q<thor>, [">= 0.9.7"])
    else
      s.add_dependency(%q<json>, [">= 0"])
      s.add_dependency(%q<activesupport>, [">= 2.1.0"])
      s.add_dependency(%q<eventmachine>, [">= 0.12.0"])
      s.add_dependency(%q<thor>, [">= 0.9.7"])
    end
  else
    s.add_dependency(%q<json>, [">= 0"])
    s.add_dependency(%q<activesupport>, [">= 2.1.0"])
    s.add_dependency(%q<eventmachine>, [">= 0.12.0"])
    s.add_dependency(%q<thor>, [">= 0.9.7"])
  end
end
