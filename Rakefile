require 'rake/testtask'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name        = "marvin"
    s.summary     = "Ruby IRC Library / Framework"
    s.email       = "sutto@sutto.net"
    s.homepage    = "http://blog.ninjahideout.com/"
    s.description = "Marvin is a Ruby IRC library / framework for ultimate awesomeness and with an evented design."
    s.authors     = ["Darcy Laycock"]
    # Non-standard files to be included.
    extras        = ["config/setup.rb", "config/boot.rb", "config/settings.yml.sample", "config/connections.yml.sample"]
    s.files       = FileList["[A-Z]*.*", "{bin,generators,lib,test,spec,script,handlers}/**/*"] + extras
    s.executables = "marvin"
    # Our dependencies
    s.add_dependency "Sutto-perennial"
    s.add_dependency "eventmachine",  ">= 0.12.0"
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

Rake::TestTask.new do |t|
 t.libs << "test"
 t.test_files = FileList['test/*_test.rb']
 t.verbose = true
end