

class DeployJob < Struct.new(:deployment_id)
  def enqueue(job)
    # Called when job is queued
    deployment = DeploymentObject.find(deployment_id)
    deployment.status = "Queued"
    deployment.save!
  end

  def before(job)
    deployment = DeploymentObject.find(deployment_id)
    deployment.status = "Running"
    deployment.save!
  end

  def perform
    deployment = DeploymentObject.find(deployment_id)
    @tasks = deployment.tasks
    @tasks.each do |task|
      deployment.log_message("Starting #{task.label}")
      sleep(5)
      deployment.log_message("Finished #{task.label}")
    end
  end
  
  def after(job)
    # Called after job
  end
  
  def success(job)
    # Called on success
    deployment = DeploymentObject.find(deployment_id)
    deployment.status = "OK"
    deployment.save!
  end
  
  def failure
    # Called on failure
    deployment = DeploymentObject.find(deployment_id)
    deployment.status = "Failed"
    deployment.save!
  end
  
  def error(job, exception)
    # Called on error
  end
end