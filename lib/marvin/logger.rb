module Marvin
  class Logger
    
    cattr_accessor :logger
    
    class << self
      
      def setup
        log_path = Marvin::Settings.root / "log/#{Marvin::Settings.environment}.log"
        self.logger ||= new(log_path, Marvin::Settings.log_level, Marvin::Settings.verbose)
      end
      
      def method_missing(name, *args, &blk)
       self.setup # Ensure the logger is setup
       self.logger.send(name, *args, &blk)
      end
    
    end
    
    
    LEVELS = {
      :fatal => 7,
      :error => 6,
      :warn  => 4,
      :info  => 3,
      :debug => 0
    }
  
    PREFIXES = {}
  
    LEVELS.each { |k,v| PREFIXES[k] = "[#{k.to_s.upcase}]".ljust 7 }

    COLOURS = {
      :fatal => 31, # red
      :error => 33, # yellow
      :warn  => 35, # magenta
      :info  => 32, # green
      :debug => 34   # white
    }
  
    attr_accessor :level, :file, :verbose
  
    def initialize(path, level = :info, verbose = false)
      self.level   = level.to_sym
      self.verbose = verbose
      self.file    = File.open(path, "a+")
    end
  
    def close!
      self.file.close
    end
  
    LEVELS.each do |name, value|
    
      define_method(name) do |message|
        write "#{PREFIXES[name]} #{message}", name if LEVELS[self.level] <= value
      end
    
      define_method(:"#{name}?") do
        LEVELS[self.level] <= value
      end    
    end
  
    def debug_exception(exception)
    
      error "Exception: #{exception}"
      exception.backtrace.each do |l|
        error ">> #{l}"
      end
    
    end
  
    private
  
    def write(message, level = self.level)
      self.file.puts message
      STDOUT.puts colourize(message, level) if self.verbose
    end
  
    def colourize(message, level)
      "\033[1;#{COLOURS[level]}m#{message}\033[0m"
    end
 
    
  end
end