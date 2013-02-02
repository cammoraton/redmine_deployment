require "delayed_job"

class DeploymentObject < ActiveRecord::Base
  include Redmine::SafeAttributes
  unloadable
  
  belongs_to :deployment_server
  belongs_to :changeset
  
  has_many :issues
  
  validates_uniqueness_of :changeset_id, :deployment_server_id
  
  safe_attributes 'description',
    'status',
    'deployed_on',
    'log'
  
  def queue_job
    Delayed::Job.enqueue DeployJob.new(self.id), :queue => self.deployment_server.name, :attempts => 5
  end
  
  def job_status
    
  end
end    

#https://github.com/collectiveidea/delayed_job