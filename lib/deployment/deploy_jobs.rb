# Load everything in the jobs directory
Dir[File.join(File.dirname(__FILE__), 'jobs', '*.rb')].each {|file| require_dependency file.gsub('.rb', '') } 


class DeployJob < Struct.new(:deployment_id)
  def enqueue(job)
    # Called when job is queued
    @deployment = DeploymentObject.find(deployment_id)
    @deployment.status = "Queued"
    @deployment.save!
    # Invalidate any other non-finished jobs
    # If something is already running, and the rails lock mechanisms have failed
    # then kill ourself
  end

  def before(job)
    @deployment = DeploymentObject.find(deployment_id)
    @deployment.status = "Running"
    @deployment.save!
  end

  def perform
    @deployment = DeploymentObject.find(deployment_id)
    @tasks = @deployment.tasks
    @tasks.each do |task|
      @deployment.log_message("Starting #{task.label}")
      sleep(5)
      @client = RemoteSCM::McollectiveSCM.new("andwebprod.terc.edu", "/web/websites/projects/mspnet")
      puts @client.info
      @deployment.log_message("Finished #{task.label}")
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