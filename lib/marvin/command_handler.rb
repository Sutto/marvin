require 'set'

module Marvin
  class CommandHandler < Base
    
    class_inheritable_accessor :command_prefix
    self.command_prefix  = ""
    
    @@exposed_method_mapping = Hash.new { |h,k| h[k] = [] }
    @@method_descriptions    = Hash.new { |h,k| h[k] = {} }
    
    class << self
      
      def command(name, method_desc = nil, &blk)
        exposes name
        desc method_desc unless method_desc.blank?
        define_method(name, &blk)
      end
      
      def prefix_is(p)
        self.command_prefix = p
      end
      
      def exposes(*args)
        args.each { |name| @@exposed_method_mapping[self] << name.to_sym }
      end
      
      def exposed_methods
        methods = []
        klass   = self
        while klass != Object
          methods += @@exposed_method_mapping[klass]
          klass = klass.superclass
        end
        return methods.uniq.compact
      end
      
      def prefix_regexp
        /^#{command_prefix}/
      end
      
      def desc(description)
        @last_description = description
      end
      
      def exposed_name(method)
        "#{command_prefix}#{method}"
      end
      
      def reloading!
        super
        @@exposed_method_mapping.delete(self)
        @@method_descriptions.delete(self)
      end
      
    end
    
    on_event :incoming_message, :check_for_commands
    
    def check_for_commands
      message = options.message.to_s.strip
      data, command = nil, nil
      if from_channel?
        name, command, data = message.split(/\s+/, 2)
        return if name !~ /^#{client.nickname}:/i
      else
        command, data = message.split(/\s+/, 2)
      end
      data ||= ""
      if (command_name = extract_command_name(command)).present?
        logger.info "Processing command '#{command_name}' for #{from}"
        send(command_name, data.to_s) if respond_to?(command_name)
      end
    end
    
    def extract_command_name(command)
      re = self.class.prefix_regexp
      if command =~ re
        method_name = command.gsub(re, "").underscore.to_sym
        return method_name if self.class.exposed_methods.include?(method_name)
      end
    end
    
    def exposed_name(name)
      self.class.exposed_name(name)
    end
    
    def self.method_added(name)
      if @last_description.present?
        @@method_descriptions[self][name.to_sym] = @last_description
        @last_description = nil
      end
    end
    
  end
end