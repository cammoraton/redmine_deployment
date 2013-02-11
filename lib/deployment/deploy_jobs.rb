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
      
    end
  end
  
  def after(job)
    # Called after job
  end
  
  def success(job)
    # Called on success
  end
  
  def failure
    # Called on failure
  end
  
  def error(job, exception)
    # Called on error
  end
end