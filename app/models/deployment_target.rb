class DeploymentTarget < ActiveRecord::Base
  include Redmine::SafeAttributes

  unloadable
  
  belongs_to :deployment_environment

  has_many :deployment_tasks,   :dependent => :destroy, :order => 'order DESC'
  has_many :deployment_objects, :dependent => :destroy
    
  validates_uniqueness_of :hostname, :scope => :deployment_environment_id

  validates_presence_of  :hostname, :deployment_environment_id
  validates_presence_of  :repository_id, :if => :is_dummy?
   
  
  safe_attributes 'hostname',
    'description'
  
  # Sugar
  def is_dummy?
    self.is_dummy
  end 
  
  def is_default?
    self.is_default
  end
  
  def requires_comments?
    self.comments_required
  end
  
end