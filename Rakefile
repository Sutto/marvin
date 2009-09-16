require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/gempackagetask'
require File.join(File.dirname(__FILE__), "lib", "marvin")

spec = Gem::Specification.new do |s|
  s.name     = 'marvin'
  s.email    = 'sutto@sutto.net'
  s.homepage = 'http://sutto.net/'
  s.authors  = ["Darcy Laycock"]
  s.version  = Marvin.version(ENV['RELEASE'].blank?)
  s.summary  = "Evented IRC Library of Doom"
  s.files    = FileList["{bin,lib,templates,test,handlers}/**/*"].to_a
  s.platform = Gem::Platform::RUBY
  s.add_dependency "Sutto-perennial",           ">= 0.2.4.6"
  s.add_dependency "eventmachine-eventmachine", ">= 0.12.9"
  s.add_dependency "json"
end

task :default => "test:units"

namespace :test do
  desc "Runs the unit tests for perennial"
  Rake::TestTask.new("units") do |t|
    t.pattern = 'test/*_test.rb'
    t.libs << 'test'
    t.verbose = true
  end  
end


Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

task :gemspec do
  File.open("marvin.gemspec", "w+") { |f| f.puts spec.to_ruby }
end

def gemi(name, version)
  command = "gem install #{name} --version '#{version}' --source http://gems.github.com"
  puts ">> #{command}"
  system "#{command} 1> /dev/null 2> /dev/null"
end

task :install_dependencies do
  spec.dependencies.each do |dependency|
    gemi dependency.name, dependency.requirement_list.first
  end
end

task :check_dirty do
  if `git rev-parse HEAD` != `git rev-parse origin/master`
    puts "You have unpushed changes. Please push them first"
    exit!
  end
  if `git status`.include? 'added to commit'
    puts "You have uncommited changes. Please commit them first"
    exit!
  end
end

task :tag => :check_dirty do
  version = Marvin.version(ENV['RELEASE'].blank?)
  command = "git tag -a v#{version} -m 'Code checkpoint for v#{version}'"
  puts ">> #{command}"
  system command
end

