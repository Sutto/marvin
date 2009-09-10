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

      class ServerMock < Marvin::IRC::Server::BaseConnection
        def send_line(line)
          puts ">> #{line}"
        end
        def kill_connection!
          puts "Killing connection"
        end

        def get_peername
          # Localhost, HTTP
          "\034\036\000P\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\001\000\000\000\000"
        end

        def host
          "localhost"
        end

        def port
          6667
        end

      end

      def server(reset = false)
        $server = ServerMock.new(:port => 6667, :host => "localhost") if $server.blank? || reset
        return $server
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
      IRB.start(@file)
    end
    
    def self.run
      self.new.run
    end
    
  end
end