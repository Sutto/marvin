require 'set'

module Marvin
  
  # A Simple Marvin handler based on processing
  # commands, similar in design to MatzBot.
  class CommandHandler < Base
    
    class_inheritable_accessor :exposed_methods, :command_prefix
    cattr_accessor :descriptions, :last_description, :exposed_method_names
    
    self.command_prefix       = ""
    self.exposed_methods      = Set.new
    self.descriptions         = {}
    self.exposed_method_names = Set.new
    
    class << self
      
      def exposes(*args)
        names = args.map { |a| a.to_sym }.flatten
        self.exposed_methods      += names
        self.exposed_method_names += names
      end
      
    end
    
    on_event :incoming_message do
      logger.debug "Incoming message"
      check_for_commands
    end
    
    def check_for_commands
      data, command = nil, nil
      if self.from_channel?
        logger.debug "Processing command in channel"
        split_message = options.message.split(" ", 3)
        prefix = split_message.shift
        # Return if in channel and it isn't address to the user.
        return unless prefix == "#{self.client.nickname}:"
        command, data = split_message # Set remaining.
      else
        command, data = options.message.split(" ", 2)
      end
      # Double check for sanity
      return if command.blank?
      command_name = extract_command_name(command)
      unless command_name.nil?
        logger.debug "Command Exists - processing"
        # Dispatch the command.
        self.send(command_name, data.to_s.split(" ")) if self.respond_to?(command_name)
      end
    end
    
    def extract_command_name(command)
      prefix_length = self.command_prefix.to_s.length
      has_prefix = command[0...prefix_length] == self.command_prefix.to_s
      if has_prefix
        method_name = command[prefix_length..-1].to_s.underscore.to_sym
        return method_name if self.exposed_methods.to_a.include?(method_name)
      end
    end
    
    class << self
      
      def desc(desc)
        self.last_description = desc
      end
      
      def method_added(name)
        unless last_description.blank?
          descriptions[name.to_sym] = self.last_description
          self.last_description = nil
        end
      end
      
    end
    
  end
  
end