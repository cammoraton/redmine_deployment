# Load everything in the jobs directory
Dir[File.join(File.dirname(__FILE__), 'jobs', '*.rb')].each {|file| require_dependency file.gsub('.rb', '') } 
Dir[File.join(File.dirname(__FILE__), 'rpcs', '*.rb')].each {|file| require_dependency file.gsub('.rb', '') } 


class DeployJobSoftFailureException < Exception
  # A soft failure, will retry
end

class DeployJobHardFailureException < Exception
  # A hard failure, will not retry
end

class DeployJobRollbackException < Exception
  # A failure of any kind in a job with multiple rpc calls
  # To trigger a rollback
end

class DeployJob < Struct.new(:deployment_id)
  def enqueue(job)
    # Called when job is queued
    deployment = DeploymentObject.find(deployment_id)
    deployment.status = "Queued"

    deployment.save!
  end

  def before(job)
    deployment = DeploymentObject.find(deployment_id)
    deployment.run(job.id)
    
    # TODO: Handle rollback types
    # Reverify we're the only job running
    others = deployment.other_deployments
    unless others.nil?
      unless others.empty?
        if others.first.delayed_job_id != job.id
          raise DeployJobHardFailureException, "An earlier job is queued or running"
        end
      end
    end
  end

  def perform
    deployment = DeploymentObject.find(deployment_id)
    deployment.log_message("Starting deployment")
    tasks = deployment.tasks
    begin
      #TODO: We should have a flag to atomize tasks.
      #TODO: We should have a flag to retry
      #TODO: We should have a method to perform rollbacks
      tasks.each do |task|
        deployment.log_message("Starting task \"#{task.label}\"")
        case task.task_type
        when 'scm'
         @job = DeployJobTask::SCM.new(deployment, task)
        when 'permissions'
         @job = DeployJobTask::Permissions.new(deployment, task)
        when 'verify'
         @job = DeployJobTask::Verify.new(deployment, task)
        when 'hudson'
         @job = DeployJobTask::Hudson.new(deployment, task)
        when 'capistrano'
         @job = DeployJobTask::Capistrano.new(deployment, task)
        when 'trigger'
         @job = DeployJobTask::Trigger.new(deployment, task)
        when 'puppet'
         @job = DeployJobTask::Puppet.new(deployment, task)
        when 'service'
         @job = DeployJobTask::Service.new(deployment, task)
        else
         raise DeployJobHardFailureException, "Unknown task type #{task.task_type}"
        end
        puts @job.object_id
        @job.run()
        deployment.log_message("Task \"#{task.label}\" complete")
        # TODO: Update last successful task for rollback
      end
   # rescue DeployJobSoftFailureException => e
      # Soft failure
   #   deployment.log_message("Deployment failed - #{e.message}")
   #   deployment.fail
    end
  end
  
  def success(job)
    # Called on success
    deployment = DeploymentObject.find(deployment_id)
    deployment.delayed_job_id = nil
    deployment.log_message("Deployment complete")
    deployment.status = "OK"
    deployment.save!
  end

  def error(job, e)
    deployment = DeploymentObject.find(deployment_id)
    deployment.log_message("Deployment failed: #{e.message}")
    deployment.fail
  end
end