begin
  require 'mcollective'
rescue LoadError => e
  # No mcollective, probably because the stomp gem is absent
end

class MCollectiveSVNException < Exception
  # Generic errors we should probably stop on
end

class MCollectiveSVNStatusCodeException < Exception
  # A status code error.  We'll probably act on this in a way other than outright failure
end

# TODO: Status code checks aren't right

# Need to check if mcollective is loaded before this.
# We probably want specific error handling if mcollective is not installed and you try to use it
# IE: Go install mcollective you mook
if defined?(MCollective)
module DeploymentRPC
  class MCollectiveSVN
    include MCollective::RPC
    
    # TODO: MCORPC Error handling.
    def initialize(node, path)

      @path = path
      @node = node
      # Make sure the file exists if not default to the defaults(/etc/mcollective/client.cfg,
      # which is probably owned by root and will bomb out)
      options =  MCollective::Util.default_options
      options[:config] = 'plugins/deployment/config/mcollective.cfg'
      @client = rpcclient("subversion", :options => options)
      # Check if node and path are strings .is_a? String  Raise exception otherwise
      @client.identity_filter @node
    end
  
    def update(current_revision, uri, revision)
      # Return checkout if no current_revision
      return checkout(uri,revision) if @current_revision.nil?
      
      # The view should've caught this, but double check.
      if @current_revision == revision
        raise MCollectiveSVNException, "Nothing to do" 
      end
      
      # Check that the expected equals what we have
      if current_revision != @current_revision
        update_info  # Update the information on a mismatch
        if current_revision != @current_revision  # Recheck it
          # Raise an exception
          raise MCollectiveSVNException, "Remote revision does not match expected revision, manual intervention required, to bring back into sync update remote copy to Revision \##{current_revision}"
        end
      end

      # TODO: We should massage the uris more       
      # If the uri doesn't match, then the repository has changed and we should do a fresh checkout
      if uri.chomp('/') != @current_uri.chomp('/')
        checkout(uri,revision)
      else
        # Otherwise do the update
        @client.update(:path => @path, :revision => revision) do |resp|
          if resp[:senderid] != @node
            # raise exception
            raise MCollectiveSVNException, "Senderid/node mismatch - #{@node} != #{resp[:senderid]}"
          end
          if resp[:body][:statuscode] != 0
            # raise exception
            # This should be expected on a fresh checkout/new deploy
            raise MCollectiveSVNStatusCodeException, resp[:body][:statusmsg]
          end
        end
        update_info # And update the info again
        
        # Make sure the revision information now matches
        if revision != @current_revision
          raise MCollectiveSVNException, "Post-update revision mismatch - #{current_revision} != #{@current_revision}"
        end
      end
    end
  
    def checkout(uri, revision, clear = false)
      # We always force an update
      
      ttl = @client.ttl
      
      # Set the ttl to 5 minutes if less than 5 minutes(checkouts can take a while)
      if ttl < 300
        @client.ttl = 300
      end
      @client.checkout(:path => @path, :revision => revision, :uri => uri, :clear => clear) do |resp|
        puts resp[:body][:data]
        if resp[:senderid] != @node
          # raise exception
          raise MCollectiveSVNException, "Senderid/node mismatch on response - #{@node} != #{resp[:senderid]}"
        end
        if resp[:body][:statuscode] != 0
          # Something went wrong that we may want to handle
          raise MCollectiveSVNStatusCodeException, resp[:body][:statusmsg]
        end
      end
      @client.ttl = ttl
    end

    def update_info
      @current_revision = nil
      @current_uri = nil
      @client.info(:path => @path) do |resp|
        if resp[:senderid] != @node
          # raise exception
          raise MCollectiveSVNException, "Senderid/node mismatch on response - #{@node} != #{resp[:senderid]}"
        end
        if resp[:body][:statuscode] != 0
          # This should be expected on a fresh checkout/new deploy
          raise MCollectiveSVNStatusCodeException, resp[:body][:statusmsg]
        end
        @current_revision = resp[:body][:data][:revision]
        @current_uri = resp[:body][:data][:url]
        # Also have :last_changed_date, :root, :last_changed_rev, and :author
      end
    end
  end
end
end