require "delayed_job"

class DeploymentObject < ActiveRecord::Base
  include Redmine::SafeAttributes
  unloadable
  
  attr_accessor :workflow_id
  
  belongs_to :deployment_server
  belongs_to :changeset
  
  has_many :issues
  
  validates_presence_of :changeset_id, :deployment_server_id
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
  
  def workflow_id
    self.deployment_server.deployment_workflow_id
  end
end    

#https://github.com/collectiveidea/delayed_job