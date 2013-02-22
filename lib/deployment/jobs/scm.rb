module DeployJobTask
  class SCM
    def initialize(deployment, task_name )
      @deployment = deployment
      @target = @deployment.deployment_target.hostname
      @revision = @deployment.changeset.revision
      @path = @deployment.deployment_target.deployment_path
      @uri = @deployment.deployment_target.remote_uri
      @task_name = task_name
      unless @deployment.last_revision.nil?
        @current_revision = @deployment.last_revision
      else
        @current_revision = @revision
      end
      log("#{@task_name}: Connecting to target")
      @rpcclient = init_client
      log("#{@task_name}: Connected to target")
    end

    def run
      if defined?(MCollective)
        begin
          @rpcclient.update_info
          log("#{@task_name}: Updating to revision #{@revision}")
        rescue MCollectiveSVNStatusCodeException => e
          log("#{@task_name}: Executing fresh deployment with revision #{@revision}")
          # Set the clear deployment flag on the target
        end
      end
      update
    end
    
    private
    def log(message)
      @deployment.log_message(message)
    end
    
    def init_client
      if defined?(MCollective)
      begin
        client = DeploymentRPC::MCollectiveSVN.new(@target, @path)
      rescue MCollectiveSVNException => e
        log("#{@task_name}: Error connecting: #{e.message}")
        # Generic exception, only thrown in circumstances where we probably want to hard fail
        raise DeployJobHardFailureException, e.message
      rescue MCollectiveSVNStatusCodeException => e
        # Status code error.  Could be a number of things.
        log("#{@task_name}: Error connecting: #{e.message}")
        raise DeployJobSoftFailureException, e.message
      
      end
      end
      client
    end
    
    def update
      if defined?(MCollective)
      begin
        @rpcclient.update(@current_revision, @uri, @revision)
      rescue MCollectiveSVNException => e
        log("#{@task_name}: Error updating: #{e.message}")
        # Generic exception, only thrown in circumstances where we probably want to hard fail
        raise DeployJobHardFailureException, e.message
      rescue MCollectiveSVNStatusCodeException => e
        # Check for expected status code errors that we can compensate for
        
        # If uris or revisions don't match then do a fresh checkout
        
        # Not a status code error we expect
        log("#{@task_name}: Error updating: #{e.message}")
        raise DeployJobSoftFailureException, e.message
      rescue Exception => e
        # Unknown exception, probably thrown by MCollective, hard fail
        log("#{@task_name}: Error updating: #{e.message}")
        raise DeployJobHardFailureException, e.message
      end
      end
    end
    
    def checkout
    
    end
  end
end