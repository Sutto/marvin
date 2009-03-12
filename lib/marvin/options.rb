require 'optparse'

module Marvin
  class Options
  
    def self.parse!
      options = {
        :verbose   => Marvin::Settings.verbose,
        :log_level => Marvin::Settings.log_level.to_s,
        :daemon    => false
      }
      
      ARGV.options do |o|
        script_name = File.basename($0)
        o.set_summary_indent('    ')
        o.banner =    "Usage: #{script_name}  [OPTIONS]"
        o.define_head "Ruby IRC Library"
        o.separator   ""
        o.separator   ""
        o.on("-l", "--level=[level]", String, "The log level to use",
             "Default: #{options[:log_level]}") {|v| options[:log_level] = v}
        o.on("-v", "--verbose", "Be verbose (print to stdout)") {|v| options[:verbose] = v}
        o.on("-d", "--daemon",  "Run as a daemon (drop the PID)") {|v| options[:daemon] = v}
        o.on("-k", "--kill", "Kill all of the current type / the running instances") do |kill|
           if kill
            Marvin::Daemon.kill_all(Marvin::Loader.type)
            exit
          end
        end
        
        o.separator   ""
        o.on_tail("-h", "--help", "Show this message.") { puts o; exit }
        o.parse!
      end
      
      Marvin::Settings.daemon    = options[:daemon]
      Marvin::Settings.log_level = options[:log_level].to_sym
      Marvin::Settings.verbose   = options[:verbose]
    end
  
  end
end