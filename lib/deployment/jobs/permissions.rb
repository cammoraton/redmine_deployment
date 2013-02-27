# This is pretty barebones, like the ssh it's really
# just an extra method to use.

module DeployJobTask
  class Permissions
    def initialize(deployment, task, recurse = nil)
      @deployment = deployment
      @target = @deployment.deployment_target.hostname
      
      if task.metadata[:relative_path] and task.metadata[:relative_path].length > 0
        @path = @deployment.deployment_target.deployment_path + task.metadata[:relative_path]
      else
        @path = @deployment.deployment_target.deployment_path
      end
      @task_name = task.label

      # This will default to 0 length strings, so we need to
      # explicitly set them to nil before setting them again
      # if values are set in the metadata
      @owner   = nil
      @group   = nil
      @mode    = nil
      @recurse = nil
      
      @owner   = task.metadata[:owner] if task.metadata[:owner] and task.metadata[:owner].length > 0
      @group   = task.metadata[:group] if task.metadata[:group] and task.metadata[:group].length > 0
      @mode    = task.metadata[:mode]  if task.metadata[:mode]  and task.metadata[:mode].length > 0
      if recurse.nil?
        @recurse = task.metadata[:recursive] if task.metadata[:recursive] and task.metadata[:recursive].length > 0
        # Explicitly convert the checkbox val to an int and then manually set it to a bool
        if @recurse.to_i > 0
          @recurse = true
        else 
          @recurse = false
        end
      else
        @recurse = recurse
      end
        
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
          arguments = Hash.new
          arguments[:owner]   = @owner   unless @owner.nil?
          arguments[:group]   = @group   unless @group.nil?
          arguments[:mode]    = @mode    unless @mode.nil?
          arguments[:recurse] = @recurse unless @recurse.nil?
          arguments[:path]    = @path
          @rpcclient.change_perms(arguments)
          @rpcclient.close
        rescue MCollectiveFilePermsException => e
          log("#{@task_name}: Error modifying permissions: #{e.message}")
          # Generic exception, only thrown in circumstances where we probably want to hard fail
          raise DeployJobHardFailureException, e.message
        rescue MCollectiveFilePermsStatusCodeException => e
          # Status code error.  Could be a number of things.
          log("#{@task_name}: Error modifying permissions: #{e.message}")
          raise DeployJobSoftFailureException, e.message
        rescue Exception => e
          # Unknown exception, probably thrown by MCollective, hard fail
          log("#{@task_name}: Error modifying permissions: #{e.message}")
          raise DeployJobHardFailureException, e.message
        end
      end
    end
    
    private
    def log(message)
      @deployment.log_message(message)
    end
    
    def init_client
      if defined?(MCollective)
      begin
        client = DeploymentRPC::MCollectiveFilePerms.new(@target, @path)
      rescue MCollectiveFilePermsException => e
        log("#{@task_name}: Error connecting: #{e.message}")
        # Generic exception, only thrown in circumstances where we probably want to hard fail
        raise DeployJobHardFailureException, e.message
      rescue MCollectiveFilePermsStatusCodeException => e
        # Status code error.  Could be a number of things.
        log("#{@task_name}: Error connecting: #{e.message}")
        raise DeployJobSoftFailureException, e.message
      rescue Exception => e
        # Unknown exception, probably thrown by MCollective, hard fail
        log("#{@task_name}: Error connecting: #{e.message}")
        raise DeployJobHardFailureException, e.message
      end
      end
      client
    end
  end
end