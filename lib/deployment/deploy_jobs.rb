class DeployJob < Struct.new(:deployment_id)
  def enqueue(job)
    # Called when job is queued
  end

  def before(job)
    # Called before job is run
  end

  def perform
    deployment = Deployment.find(deployment_id)
    deployment.status = "Running"
    sleep(5)
    deployment.status = "Ran"
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