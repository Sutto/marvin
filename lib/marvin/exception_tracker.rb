module Marvin
  class ExceptionTracker
  
    cattr_accessor :logger
    self.logger = Marvin::Logger.logger
  
    def self.log(e)
      logger.fatal "Exception raised inside Marvin Instance."
      logger.fatal "#{e} - #{e.message}"
      e.backtrace.each do |line|
        logger.fatal line
      end
    end
  
  end
end