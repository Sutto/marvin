require File.join(File.dirname(__FILE__), '..', 'lib', "marvin")
Marvin::Settings.root = Pathname.new(__FILE__).dirname.join("..").expand_path