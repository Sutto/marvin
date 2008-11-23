MARVIN_ROOT = File.join(File.dirname(__FILE__), "../..")
Marvin::Settings.verbose   = true
Marvin::Settings.log_level = :debug
Marvin::Settings.default_client = Marvin::TestClient
Marvin::Loader.run! :console

def parse(line)
  Marvin::Settings.default_parser.parse(line)
end

def logger
  Marvin::Logger.logger
end

def client
  $client ||= Marvin::Settings.default_client.new(:port => 6667, :server => "irc.freenode.net")
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