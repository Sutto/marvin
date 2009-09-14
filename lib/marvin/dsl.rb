# Handy Dandy DSL style stuff for Marvin
module Marvin
  class DSL
  
    class Proxy < Perennial::Proxy
      
      def initialize(klass)
        @prototype_klass = Class.new(klass)
        @mapping         = {}
      end
      
      def define_shortcut(name, method_name)
        @mapping[name] = method_name
      end
      
      def shortdef(hash = {})
        hash.each_pair { |k,v| define_shortcut(k, v) }
      end
      
      
      
      def initialize_class!
        @klass = Class.new(@prototype_klass)
      end
      
      def to_instance
        @klass.new
      end
      
      def to_class
        @klass
      end
      
      def method_missing(name, *args, &blk)
        name = name.to_sym
        if @mapping.has_key?(name)
          @klass.define_method(@mapping[name], &blk)
        else
          @klass.send(name, *args, &blk)
        end
      end
      
    end
  
    def initialize(&blk)
      instance_eval(&blk)
    end
    
    def logging(&blk)
      call_prototype(:logging, &blk).register!
    end
    
    def handler(&blk)
      call_prototype(:handler, &blk).register!
    end
    
    def commands(&blk)
      call_prototype(:commands, &blk).register!
    end
    
    def configure(&blk)
      Marvin::Settings.client.configure(&blk)
    end
    
    def server(name, port = nil)
      name = name.to_s.dup
    end
      
    
    
    protected
    
    def initialize_prototypes
      prototype_for(:logging, Marvin::LoggingHandler) do
        shortdef :setup    => :setup_logging,
                 :teardown => :teardown_logging,
                 :incoming => :log_incoming,
                 :outgoing => :log_outgoing,
                 :message  => :log_message
      end
      prototype_for(:handler, Marvin::Base) do
        map :on      => :on_event,
            :numeric => :on_numeric
      end
      prototype_for(:handler, Marvin::CommandHandler)
    end
    
    def prototype_for(name, klass, &blk)
      @prototypes ||= {}
      p = Proxy.new(klass)
      p.instance_eval(&blk)
      @prototypes[name] = p
    end
    
    def call_prototype(name, &blk)
      p = @prototypes[name]
      p.initialize_class!
      p.instance_eval(&blk)
      return p.to_class
    end
    
  end
end