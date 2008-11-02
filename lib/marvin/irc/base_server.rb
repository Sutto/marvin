require 'webrick'

module Marvin::IRC
  class BaseServer < WEBrick::GenericServer
    
    def run(sock)
      File.open("x", "w+") { |f| f.puts sock.inspect }
    end
    
  end
end