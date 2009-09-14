require 'irb'

module Marvin
  class Console
    
    module BaseExtensions
      def parse(line)
        Marvin::Settings.parser.parse(line)
      end

      def logger
        Marvin::Logger.logger
      end

      def client
        $client ||= Marvin::Settings.client.new(:port => 6667, :server => "irc.freenode.net")
      end

      def user(reset = false)
        unless @user_created || reset
          server.receive_line "NICK SuttoL"
          server.receive_line "USER SuttoL 0 * :SuttoL"
          @user_created = true
        end
        return server.connection_implementation
      end
    end
    
    def initialize(file = $0)
      @file = file
      setup_irb
    end
    
    def setup_irb
      # This is a bit hacky, surely there is a better way?
      # e.g. some way to specify which scope irb runs in.
      eval("include Marvin::Console::BaseExtensions", TOPLEVEL_BINDING)
    end
    
    def run
      ARGV.replace []
      IRB.start
    end
    
    def self.run
      self.new.run
    end
    
  end
end