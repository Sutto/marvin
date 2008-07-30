module Marvin
  
  class Error < StandardError; end
  
  # Used to stop the flow of handler chains.
  class HaltHandlerProcessing < Error; end
  
end