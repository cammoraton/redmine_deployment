require 'fileutils'
require 'etc'

#TODO: SELinux stuffs
# Will not work on windows, and I have no intention of fixing that anytime soon

module MCollective
  module Agent
    class Fileperms<RPC::Agent
      authorized_by :action_policy      
      
      # Different actions just have different validations
      # Made more sense to do it this way since you couldn't to my knowledge
      # have a default action
      [ "chown","chgrp","chmod" ].each do |act|
        action act do
          run
        end
      end
      
      def get_path
        request[:path]
      end
      
      def get_owner
        request[:owner]
      end
      
      def get_group
        request[:group]
      end
      
      def get_mode
        request[:mode]
      end
      
      def get_recurse
        request[:recurse]
      end
      
      private
      def run
        path = get_path
        owner = get_owner
        group = get_group
        mode = get_mode
        recurse = get_recurse 
        reply[:output] = "Checking for existence of file"
        if File.exists?(path)
          # We use the fileutils wrappers around file/etc/yada yada
          if owner or group
            if recurse
              FileUtils.chown_R owner, group, path, :verbose => true
            else 
              FileUtils.chown owner, group, path, :verbose => true
            end
          end
          
          if mode
            if mode.is_a? String and mode.match(/^\d/)
              mode = mode.to_i(8)
            end
            if recurse
              FileUtils.chmod_R mode, path, :verbose => true
            else
              FileUtils.chmod mode, path, :verbose => true
            end
          end
        else
          reply[:output] = "Nothing at '#{path}'"
          logger.warn("Nothing at '#{path}'")
          reply.fail! "Invalid path.  Nothing there"
        end
      end
    end
  end
end