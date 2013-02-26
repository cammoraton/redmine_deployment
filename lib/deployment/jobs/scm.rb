module DeployJobTask
  class SCM
    def initialize(deployment, task)
      @deployment = deployment
      @target = @deployment.deployment_target.hostname
      @revision = @deployment.changeset.revision
      @path = @deployment.deployment_target.deployment_path
      @uri = @deployment.deployment_target.remote_uri

      @task = task
      @task_name = @task.label
      @owner = @task.metadata[:owner]
      @group = @task.metadata[:group]
      
      unless @deployment.last_revision.nil?
        @current_revision = @deployment.last_revision
      else
        @current_revision = @revision
      end
      
      puts "#{@current_revision} / #{@revision}"
      log("#{@task_name}: Connecting to target")
      @rpcclient = init_client
      log("#{@task_name}: Connected to target")
    end

    def run
      if defined?(MCollective)
        begin
          @rpcclient.update_info
          log("#{@task_name}: Updating to revision #{@revision}")
        # A status code exception is expected on updating info
        # if things haven't been deployed before
        rescue MCollectiveSVNStatusCodeException => e
          log("#{@task_name}: Executing fresh deployment with revision #{@revision}")
          # Set the clear deployment flag on the target
        end
      end
      update
      log("#{@task_name}: Update successful")

      if !@owner.nil?
        unless @group.nil?
          update_perms if @group.length > 0 or @owner.length > 0
        else
          update_perms if @owner.length > 0
        end
      elsif !@group.nil?
        update_perms if @group.length > 0
      end
      
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
      rescue Exception => e
        # Unknown exception, probably thrown by MCollective, hard fail
        log("#{@task_name}: Error updating: #{e.message}")
        raise DeployJobHardFailureException, e.message
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
    
    def update_perms
      begin
        log("#{@task_name}: Modifying permissions. ")
        job = DeployJobTask::Permissions.new(@deployment, @task, true)
        job.run()
        log("#{@task_name}: Permissions modified. ")
      rescue Exception => e
        raise DeployJobRollbackException, e.message
      end
    end
  end
end