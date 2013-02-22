# Load everything in the jobs directory
Dir[File.join(File.dirname(__FILE__), 'jobs', '*.rb')].each {|file| require_dependency file.gsub('.rb', '') } 
Dir[File.join(File.dirname(__FILE__), 'rpcs', '*.rb')].each {|file| require_dependency file.gsub('.rb', '') } 


class DeployJobSoftFailureException < Exception
  # A soft failure, will retry
end

class DeployJobHardFailureException < Exception
  # A hard failure, will not retry
end

class DeployJob < Struct.new(:deployment_id)
  def enqueue(job)
    # Called when job is queued
    deployment = DeploymentObject.find(deployment_id)
    deployment.status = "Queued"
    deployment.save!
    # Invalidate any other non-finished jobs
    # If something is already running, and the rails lock mechanisms have failed
    # then kill ourself
  end

  def before(job)
    deployment = DeploymentObject.find(deployment_id)
    deployment.status = "Running"
    deployment.save!
  end

  def perform
    deployment = DeploymentObject.find(deployment_id)
    deployment.log_message("Starting deployment")
    tasks = deployment.tasks
    begin
      tasks.each do |task|
        deployment.log_message("Starting task \"#{task.label}\"")
        case task.task_type
        when 'scm'
         job = DeployJobTask::SCM.new(deployment, task.label)
        when ''
        
        else
         raise DeployJobHardFailureException, "Unknown task type #{task.task_type}"
        end
        job.run()
      end
    rescue DeployJobSoftFailureException => e
      # Soft failure
      puts e.message
    rescue DeployJobHardFailureException => e
      # Hard failure, stop attempting
      puts e.message
    end
  end
  
  def after(job)
    # Called after job
  end
  
  def success(job)
    # Called on success
    @deployment = DeploymentObject.find(deployment_id)
    @deployment.status = "OK"
    @deployment.save!
  end
  
  def failure
    # Called on failure
    @deployment = DeploymentObject.find(deployment_id)
    @deployment.status = "Failed"
    @deployment.save!
  end
  
  def error(job, exception)
    # Called on error
  end
end