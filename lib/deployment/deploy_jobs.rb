class DeployJob < Struct.new(:deployment_id)
  def enqueue(job)
    # Called when job is queued
  end

  def before(job)
    # Called before job is run
  end

  def perform
    deployment = DeploymentObject.find(deployment_id)
    deployment.status = "Running"
    deployment.save!
    sleep(20)
    deployment.status = "OK"
    deployment.save!
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