require "delayed_job"

class DeploymentObject < ActiveRecord::Base
  include Redmine::SafeAttributes
  unloadable
  
  belongs_to :deployment_target
  belongs_to :changeset
  
  has_many :issues
  has_one  :delayed_job
  
  validates_presence_of :changeset_id
  validates_presence_of :deployment_target_id
  validates_presence_of :description, :if => :requires_comments?
  
  safe_attributes 'description',
    'status',
    'created_on',
    'updated_on',
    'log'
  
  def queue_job
    Delayed::Job.enqueue DeployJob.new(self.id), :queue => self.deployment_server.name, :attempts => 5
  end
  
  def job_status
    
  end
  
  # Sugar
  def requires_comments?
    self.deployment_target.requires_comments?
  end
  
  def environment_id
    self.deployment_target.deployment_environment.id
  end
  
  def tasks
    self.deployment_target.deployment_tasks
  end
end    
