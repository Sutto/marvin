module Marvin
  class CoreCommands < CommandHandler
    
    # Returns a hash of doccumented method names
    def self.method_documentation
      documented = Hash.new { |h,k| h[k] = [] }
      @@method_descriptions.each_key do |klass| 
        next unless klass.registered?
        @@exposed_method_mapping[klass].each do |m|
          desc = @@method_descriptions[klass][m]
          documented[m.to_s] << desc if desc.present?
        end
      end
      return documented
    end
    
    def registered_and_exposed_handlers
    end
    
    exposes :help
    desc "Generates this usage statement"
    def help(method)
      method        = method.strip
      documentation = self.class.method_documentation
      names         = documentation.keys.sort
      if method.blank?
        display_names = names.map { |n| exposed_name(n) }
        width         = display_names.map { |d| d.length }.max
        say "Hello there, I know the following documented commands:"
        names.each_with_index do |name, index|
          say "#{display_names[index].ljust(width)} - #{documentation[name].join("; ")}"
        end
      else
        if names.include? method
          reply "#{exposed_name(method)} - #{documentation[method].join("; ")}"
        else
          reply "I'm sorry, I can't help with #{m} - it seems to be undocumented."
        end
      end
    end
    
    exposes :about
    desc "Displays the current marvin and ruby versions."
    def about(*args)
      reply "Marvin v#{Marvin::VERSION} running on Ruby #{RUBY_VERSION} (#{RUBY_PLATFORM})"
    end
    
  end
end