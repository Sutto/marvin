module Marvin
  
  class Error < StandardError; end
  
  # Used to stop the flow of handler chains.
  class HaltHandlerProcessing < Error; end
  
  # Used for when an expression can't be parsed
  class UnparseableMessage < Error; end
  
end