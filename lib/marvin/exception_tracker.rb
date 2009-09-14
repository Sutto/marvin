module Marvin
  class ExceptionTracker
  
    is :loggable
    
    cattr_accessor :log_exception_proc
    self.log_exception_proc = proc { |e| e }
  
    def self.log(e)
      logger.fatal "Oh noes cap'n - we have an exception!."
      logger.fatal "#{e.class.name}: #{e.message}"
      e.backtrace.each do |line|
        logger.fatal line
      end
      @@log_exception_proc.call(e)
    end
  
  end
end