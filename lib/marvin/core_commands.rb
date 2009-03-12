module Marvin
  class CoreCommands < CommandHandler
    
    exposes :help
    desc "Generates this usage statement"
    def help(methods)
      method_names     = exposed_method_names.map { |n| n.to_s }
      documented_names = descriptions.keys.map { |k| k.to_s } & method_names 
      if methods.empty?
        width            = documented_names.map { |s| s.length }.max
        say "Hello there, I know the following commands:"
        documented_names.each { |name| say "#{name.ljust(width)} - #{descriptions[name.to_sym]}" }
        say "As well as the following undescribed commands: #{(method_names - documented_names).sort.join(", ")}"
      else
        m = methods.first
        if documented_names.include? m.to_s
          reply "#{m}: #{descriptions[m.to_sym]}"
        else
          reply "I'm sorry, I can't help with #{m} - it seems to be undocumented."
        end
      end
    end
  end
end