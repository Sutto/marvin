require 'rubygems'
require 'rake'

MARVIN_MAIN_FILE = File.join(File.dirname(__FILE__), "lib", "marvin.rb")
require MARVIN_MAIN_FILE

begin
  require 'jeweler'
  require 'perennial/jeweler_ext'
  Jeweler.versioning_via MARVIN_MAIN_FILE, Marvin::VERSION
  Jeweler::Tasks.new do |gem|
    gem.name        = "marvin"
    gem.summary     = "Evented IRC Library for Ruby, built on EventMachine and Perennial."
    gem.description = File.read("DESCRIPTION")
    gem.email       = 'sutto@sutto.net'
    gem.homepage    = 'http://sutto.net/'
    gem.authors     = ["Darcy Laycock"]
    gem.files       = FileList["{bin,lib,templates,test,handlers}/**/*"].to_a
    gem.platform    = Gem::Platform::RUBY
    gem.add_dependency "perennial",    ">= 1.0.1"
    gem.add_dependency "eventmachine", ">= 0.12.8"
    gem.add_dependency "json"
    gem.add_development_dependency "thoughtbot-shoulda"
    gem.add_development_dependency "yard"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError => e
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/*_test.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end
