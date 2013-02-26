module Deployment
  module QueryPatch
    def self.included(base)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable


      end
    end
    
    module InstanceMethods

      
    end
    
  end
end