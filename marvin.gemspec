Gem::Specification.new do |s|
  s.name     = "marvin"
  s.version  = "0.1.0.20081014"
  s.date     = "2008-08-05"
  s.summary  = "Ruby IRC Library / Framework"
  s.email    = "sutto@sutto.net"
  s.homepage = "http://github.com/sutto/marvin"
  s.description = "Marvin is a Ruby IRC library / framework for ultimate awesomeness and with an evented design."
  s.has_rdoc = true
  s.executables = ["marvin"]
  s.default_executable = "marvin"
  s.require_paths = ["lib"]
  s.requirements = ["install the eventmachine gem to get better client support"]
  s.authors  = ["Darcy Laycock"]
  s.files    = ["lib/marvin", "lib/marvin/abstract_client.rb", "lib/marvin/base.rb", "lib/marvin/command_handler.rb", "lib/marvin/core_ext.rb", "lib/marvin/data_store.rb", "lib/marvin/drb_handler.rb", "lib/marvin/exception_tracker.rb", "lib/marvin/exceptions.rb", "lib/marvin/irc", "lib/marvin/irc/client.rb", "lib/marvin/irc/event.rb", "lib/marvin/irc/socket_client.rb", "lib/marvin/irc.rb", "lib/marvin/loader.rb", "lib/marvin/logger.rb", "lib/marvin/middle_man.rb", "lib/marvin/settings.rb", "lib/marvin/test_client.rb", "lib/marvin/util.rb", "lib/marvin.rb", "bin/marvin", "config/settings.yml", "config/settings.yml.sample", "config/setup.rb", "handlers/hello_world.rb", "handlers/logging_handler.rb", "handlers/tweet_tweet.rb", "script/run", "lib/marvin/parsers/regexp_parser.rb", "lib/marvin/parsers.rb", "lib/marvin/irc/abstract_server.rb", "lib/marvin/abstract_parser.rb"]
  s.test_files = []
end