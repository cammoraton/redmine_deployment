begin
  require 'mcollective'
rescue LoadError => e
  # No mcollective, probably because the stomp gem is absent
end

# Need to check if mcollective is loaded before this.
# We probably want specific error handling if mcollective is not installed and you try to use it
# IE: Go install mcollective you mook
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
      
      # Initialize our information
      update_info  # You could play fast and loose and just not check
    end
  
    def update(current_revision, uri, revision)
      # If current revision does not equal the instance variable for current revision, recheck
      # and then raise an exception.
      
      # If the uri doesn't match, then the repository has changed and we should do a fresh checkout
      
      # Otherwise do the update
    end
  
    def checkout(uri, revision)
      # We always force an update
      
      # Set the ttl really high
    end
    
    private
    def update_info
      @client.info(:path => @path) do |resp|
        if resp[:senderid] != @node
          # raise exception
          puts "Senderid/node mismatch"
        end
        if resp[:body][:statuscode] != 1
          # raise exception
          puts "Response not ok, raise #{resp[:body][:statusmsg]}"
          # This should be expected on a fresh checkout/new deploy
        end
        @current_revision = resp[:body][:data][:revision]
        @current_uri = resp[:body][:data][:uri]
        # Also have :last_changed_date, :root, :last_changed_rev, and :author
      end
    end
  end
end