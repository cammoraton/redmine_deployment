require "delayed_job"
require "time"

class DeploymentObject < ActiveRecord::Base
  include Redmine::SafeAttributes
  unloadable
  
  belongs_to :deployment_target
  belongs_to :changeset
  belongs_to :user
  belongs_to :project, :foreign_key => 'project_id'
  
  has_many :issues
  belongs_to  :delayed_job
  
  validates_presence_of :changeset_id
  validates_presence_of :deployment_target_id
  validates_presence_of :comment, :if => :requires_comments?
  
  after_create :queue_job
  before_save  :set_project_id
  
  DEPLOYMENT_STATUSES = %w(OK Running Queued Failed)

                            
  acts_as_activity_provider :type => 'deployments',
                            :timestamp => "#{DeploymentObject.table_name}.created_on",
                            :author_key => "#{DeploymentObject.table_name}.user_id",
                            :find_options => { :include => :project,
                                               :conditions => "#{DeploymentObject.table_name}.status = 'OK'" },
                            :permission => :view_deployments
                            
  acts_as_event             :title => Proc.new { |o| 
                                  retval = "Deployed Revision #{o.changeset.revision} to #{o.deployment_target.deployment_environment.name}" if o.succeeded? 
                                  retval },
                            :description => :comment,
                            :datetime => :updated_on,
                            :type => 'deployments',
                            :author => :user,
                            :url => Proc.new {|o| { :controller => :deployments, :id => o.project, :action => 'index', :tab => 'current', :deploy_id => o.id } }

 
  
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
    return true if self.status == "Running"
  end
  
  def failed?
    return true if self.status == "Failed"
  end
  
  def succeeded?
    return true if self.status == "OK"
  end
  
  def queue
    self.status = "Queued"
    self.save!
  end
  
  def run(job_id)
    self.status = "Running"
    self.delayed_job_id = job_id
    self.save!
  end
  
  def fail
    self.status = "Failed"
    self.save!
    destroy_job
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
     
  def other_deployments
    self.deployment_target.deployment_objects.find(:all, 
                              :conditions => "status = 'Running' or status = 'Queued'",
                              :order => "\"deployment_objects\".\"created_on\"")
  end
  
  private
  def queue_job
    Delayed::Job.enqueue DeployJob.new(self.id), :queue => self.deployment_target.hostname, :attempts => 5
  end
  
  def destroy_job
    unless self.delayed_job_id.nil?
      job = Delayed::Job.find_by_id(self.delayed_job_id)
      job.destroy
    end
  end
  
  def set_project_id
    if self.project_id.nil?
      self.project_id = self.deployment_target.project.id
    end
  end
end    
