require "delayed_job"
require "time"

class DeploymentObject < ActiveRecord::Base
  include Redmine::SafeAttributes
  unloadable
  
  belongs_to :deployment_target
  belongs_to :changeset
  belongs_to :user
  
  has_many :issues
  has_one  :delayed_job
  
  validates_presence_of :changeset_id
  validates_presence_of :deployment_target_id
  validates_presence_of :comment, :if => :requires_comments?
  
  after_create :queue_job
  
  safe_attributes 'description',
    'status',
    'created_on',
    'updated_on',
    'log'
  
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
  
  def queued?
    return true if self.status == "Queued"
  end
  
  def running?
    return true unless self.status == "OK" or self.status == "Failed" 
  end
  
  def log_message(message)
    new_string = Time.now.to_formatted_s(:db) + " - " + message + "\n"
    if self.log
      self.log = new_string + self.log
    else
      self.log = new_string
    end
    self.save!
  end
  
  def last_revision
    last_deployment = self.deployment_target.last_deployment
    unless last_deployment.nil?
      changeset = last_deployment.changeset
      unless changeset.nil?
        revision = changeset.revision
        unless revision.nil?
          return revision
        end  
      end
    end
    nil
  end
  
  private
  def queue_job
    Delayed::Job.enqueue DeployJob.new(self.id), :queue => self.deployment_target.hostname, :attempts => 5
  end
end    
