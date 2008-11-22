module Marvin::IRC::Server
  class NamedStore
    
    def self.new(key_plural, ref_value, &blk)
      klass = Class.new(Hash) do
        alias_method :"each_#{ref_value}", :each_value
        alias_method key_plural.to_sym, :keys
      end
      klass.class_eval(&blk) unless blk.blank?
      return klass.new
    end
    
  end
end