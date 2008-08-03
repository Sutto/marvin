module Marvin
  
  # A Simple Marvin handler based on processing
  # commands, similar in design to MatzBot.
  class CommandHandler < Base
    
    class_inheritable_accessor :exposed_methods, :command_prefix
    
    self.command_prefix  = ""
    self.exposed_methods = []
    
    class << self
      
      def exposes(*args)
        self.exposed_methods ||= []
        self.exposed_methods += args.map { |a| a.to_sym }.flatten
      end
      
    end
    
    on_event :incoming_message do
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
      logger.debug "Raw: #{command} -> #{data}"
      command_name = extract_command_name(command)
      unless command_name.nil?
        logger.debug "Command Exists - processing"
        # Dispatch the command.
        self.send(command_name, data.to_a) if self.respond_to?(command_name)
      end
    end
    
    def extract_command_name(command)
      prefix_length = self.command_prefix.to_s.length
      has_prefix = command[0...prefix_length] == self.command_prefix.to_s
      logger.debug "Debugging, prefix is #{prefix_length} characters, has prefix? = #{has_prefix}"
      if has_prefix
        # Normalize the method name
        method_name = command[prefix_length..-1].to_s.underscore.to_sym
        logger.debug "Computed method name is #{method_name.inspect}"
        return method_name if self.exposed_methods.to_a.include?(method_name)
      end
    end
    
  end
  
end