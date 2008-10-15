require 'logger'

module Marvin
  class Logger
    
    cattr_accessor :logger
    
    class << self
      
      def setup
        log_path = Marvin::Settings.root / "log/#{Marvin::Settings.environment}.log"
        self.logger ||= ::Logger.new(Marvin::Settings.daemon? ? log_path : STDOUT)
      end
      
      def method_missing(name, *args, &blk)
       self.setup # Ensure the logger is setup
       self.logger.send(name, *args, &blk)
      end
    
    end
    
  end
end