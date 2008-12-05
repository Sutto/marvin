begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name        = "marvin"
    s.summary     = "Ruby IRC Library / Framework"
    s.email       = "sutto@sutto.net"
    s.homepage    = "http://blog.ninjahideout.com/"
    s.description = "Marvin is a Ruby IRC library / framework for ultimate awesomeness and with an evented design."
    s.authors     = ["Darcy Laycock"]
    s.files       = FileList["[A-Z]*.*", "{bin,generators,lib,test,spec,script,handlers}/**/*"] + ["config/setup.rb", "config/settings.yml.sample", "config/connections.yml.sample"]
    s.executables = "marvin"
    # Our dependencies
    s.add_dependency "json"
    s.add_dependency "activesupport", ">= 2.1.0"
    s.add_dependency "eventmachine",  ">= 0.12.0"
    s.add_dependency "thor",          ">= 0.9.7"
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end