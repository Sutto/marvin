require 'eventmachine'
module Marvin::IRC
  module Client
    
    HANDLE_TYPES = {
      /^:(\S+) 433 \* (\w+) :(.+)$/ => [:nick_taken, [:server, :current, :message]],
      /^\:(.+)\!\~?(.+)\@(.+) PRIVMSG (\#\w+) \:(.+)$/ => [:message, [:nick, :ident, :host, :target, :message]],
      /^\:(.+)\!\~?(.+)\@(.+) PRIVMSG #{Marvin::Settings.nick} \:(.+)$/ => [:private_message, [:nick, :ident, :host, :target, :message]],
      /^\:(.+)\!\~?(.+)\@(.+) PING (.*)$/ => [:pong, [:nick, :ident, :host, :data]],
      /^\:(.+)\!\~?(.+)\@(.+) QUIT (\w+) \:(.+)$/ => [:quit, [:nick, :ident, :host, :user, :message]],
      /^\:(.+)\!\~?(.+)\@(.+) PART (\w+) \:(.+)$/ => [:part, [:nick, :ident, :host, :user, :reason]],
    }
    
    def post_init
      @lines  = []
      @buffer = ""
      @in_channels = []
      Marvin::Base.instance.client = self # set the client
      send_data "USER #{Marvin::Settings.user} 0 * :#{Marvin::Settings.name} \r\n"
      nick Marvin::Settings.nick
      join Marvin::Settings.channel
    end
    
    def receive_data(data)
      @buffer << data
      Marvin::Logger.debug "Raw Data: #{data.inspect}"
      process_data
    end
    
    def unbind
    end
    
    ## Actual Client Code
    
    def process_data
      buffer_lines = @buffer.split("\r\n")
      Marvin::Logger.debug "Buffer Lines: #{buffer_lines.inspect}"
      #@buffer = ""
      #return
      if buffer_lines.length > 0 # Nonempty Buffy
        @buffer = (@buffer[-2..-1] == "\r\n") ? "" : buffer_lines.pop
        Marvin::Logger.debug "Buffer is now #{@buffer.inspect}"
        Marvin::Logger.debug "Now about to process lines: #{buffer_lines.inspect}"
        # For each line, process it unless it is empty / blank.
        buffer_lines.each { |line| process_line(line) unless line.blank? }
      end
    end
    
    def process_line(line)
      Marvin::Logger.debug "Processing Line: #{line.inspect}"
      stored_match = nil
      match = HANDLE_TYPES.detect { |re, vals| (stored_match = re.match(line)) }
      Marvin::Logger.debug "New Match: #{match.inspect}"
      Marvin::Logger.debug "Stored Match: #{stored_match.inspect} - #{match.to_a[1..-1]}"
      if match
        properties = match[1]
        name       = properties[0]
        values     = stored_match.to_a[1..-1]
        options    = Hash[*properties[1].zip(values).flatten]
        Marvin::Logger.debug "Properties: #{properties.inspect}"
        Marvin::Logger.debug "Name: #{name.inspect}"
        Marvin::Logger.debug "Values: #{values}"
        Marvin::Logger.debug "Options: #{options.inspect}"
        if Marvin::Base.instance.respond_to?("handle_#{name}")
          Marvin::Base.instance.send("handle_#{name}", options)
        end
      else
       puts "-- #{line}"
      end
    end
    
    ## Methods we can use
    
    def nick(new_nick)
      Marvin::Logger.debug "Setting Nick to #{new_nick}"
      send_data "NICK #{new_nick} \n"
    end
    
    def join(channel)
      # Append the # symbol to the front of the name
      channel = "##{channel}" unless channel[0..0] == "#"
      Marvin::Logger.debug "Joining Channel #{channel}"
      send_data "JOIN #{channel} \n"
    end
    
    def part(channel, message = nil)
      Marvin::Logger.debug "Parting #{channel}, message = #{message || 'Not Specified'}"
      send_data "PART #{channel} #{message.blank? ? "" : ":#{message} "}\r\n"
    end
    
    def pong(data)
      send_data "PONG #{data.strip}\r\n"
    end
    
    def say(message, target)
      send_data "PRIVMSG #{target} :#{message} \r\n"
    end
    
    def self.run
      EventMachine::run do
        Marvin::Logger.debug "Starting event loop w/ #{Marvin::Settings.server}:#{Marvin::Settings.port}"
        EventMachine::connect Marvin::Settings.server, Marvin::Settings.port, self
      end
    end
    
  end
end