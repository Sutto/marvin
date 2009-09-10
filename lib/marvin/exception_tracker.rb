module Marvin
  class ExceptionTracker
  
    is :loggable
  
    def self.log(e)
      logger.fatal "Oh noes cap'n - we have an exception!."
      logger.fatal "#{e.class.name}: #{e.message}"
      e.backtrace.each do |line|
        logger.fatal line
      end
    end
  
  end
end