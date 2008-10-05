task :files do
  files  = Dir["lib/**/*"]
  files += Dir["bin/**/*"]
  files += Dir["config/**/*"]
  files += Dir["handlers/**/*"]
  files += Dir["script/**/*"]
  puts files.inspect
end

task :tests do
  files = Dir["spec/**/*"]
  puts files.inspect
end

task :build => :clean do
  puts "Building gem..."
  results = `gem build marvin.gemspec`
  system "mkdir -p gems"
  if results =~ /File\: (.*)$/
    file = $1.strip
    system "mv #{file} gems/#{file}"
  else
    puts "Error building gem"
    exit(1)
  end
end

task :install => :build do
  puts "Installing Marvin..."
  to_install = Dir["gems/marvin-*.gem"].last
  system "sudo gem install #{to_install}"
end

task :clean do
  system "rm -rf gems"
end