class DeploymentTarget < ActiveRecord::Base
  include Redmine::SafeAttributes

  unloadable

  belongs_to :deployment_environment

  has_one :deployment_setting, :through => :deployment_environment
  has_one :project, :through => :deployment_environment
  
  has_many :deployment_tasks,   :dependent => :destroy, :order => '"deployment_tasks"."order"'
  has_many :deployment_objects, :dependent => :destroy
    
  validates_uniqueness_of :hostname, :scope => :deployment_environment_id

  validates_presence_of  :hostname, :deployment_environment_id
  validates_presence_of  :repository_id, :if => :is_dummy?
  
  before_save            :fix_default
  
  safe_attributes 'hostname',
    'description'
  
  # Sugar
  def is_dummy?
    self.is_dummy
  end 
  
  def is_default?
    self.is_default
  end
  
  def free?
    return false if self.deployment_objects.find_by_status('Running')
    return false if self.deployment_objects.find_by_status('Queued')
    return true
  end
  
  def requires_comments?
    self.comments_required
  end
  
  def last_deployment
    objects = self.deployment_objects.find_all_by_status('OK', :order => '"deployment_objects"."created_on"')
    return nil unless objects
    objects.last
  end
  
  def last_changeset
    self.last_deployment.changeset
  end
  
  def remote_uri
    unless self.inherit_settings
      return self.remote_scm_path
    end
    self.deployment_setting.remote_scm_path
  end
  
  def deployment_path
    unless self.inherit_settings
      return self.deploy_path
    end
    self.deployment_setting.deploy_path
  end
  
  private
  def fix_default
    if self.is_default
      self.deployment_environment.deployment_targets.each do |target|
        if target.is_default?
          target.is_default = false
          target.save!
        end
      end
    end
  end
end