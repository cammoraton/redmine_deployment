begin
  require 'mcollective'
rescue LoadError => e
  # No mcollective, probably because the stomp gem is absent
end

class MCollectiveFilePermsException < Exception
  # Generic errors we should probably stop on
end

class MCollectiveFilePermsStatusCodeException < Exception
  # A status code error.  We'll probably act on this in a way other than outright failure
end

# TODO: Status code checks aren't right

# Need to check if mcollective is loaded before this.
# We probably want specific error handling if mcollective is not installed and you try to use it
# IE: Go install mcollective you mook
if defined?(MCollective)
module DeploymentRPC
  class MCollectiveFilePerms
    include MCollective::RPC
    
    def initialize(node, path)
      @path = path
      @node = node
      # Make sure the file exists if not default to the defaults(/etc/mcollective/client.cfg,
      # which is probably owned by root and will bomb out)
      options =  MCollective::Util.default_options
      options[:config] = 'plugins/deployment/config/mcollective.cfg'
      @client = rpcclient("fileperms", :options => options)
      
      # Check if node and path are strings .is_a? String  Raise exception otherwise
      @client.identity_filter @node
      @client.progress = false
      @client.verbose = false
      # The return from a discovery should match the node as we're implictly
      # searching by node id.
      if @client.discover.to_s != @node
        raise MCollectiveSVNStatusCodeException, "Unable to find target.  Possible communications error or misconfiguration."
      end
    end
    
    def change_perms(hash)
      unless hash.is_a? Hash
        raise MCollectiveFilePermsException, "Bad argument"
      end
      @client.timeout = 300
      got_response = nil
      @client.chown(hash) do |resp|
        got_response = true
        if resp[:senderid] != @node
          # raise exception
          raise MCollectiveSVNException, "Senderid/node mismatch on response - #{@node} != #{resp[:senderid]}"
        end
        if resp[:body][:statuscode] != 0
          # This should be expected on a fresh checkout/new deploy
          raise MCollectiveSVNStatusCodeException, resp[:body][:statusmsg]
        end                
      end
      if got_response.nil?
        raise MCollectiveSVNStatusCodeException, "No response.  Communications error or timeout."
      end
    end
    
  end
end
end