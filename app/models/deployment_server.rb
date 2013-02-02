class DeploymentServer < ActiveRecord::Base
  include Redmine::SafeAttributes
  unloadable
  
  DEPLOYMENT_TYPES = %w(scm cap dummy puppet jenkins)
  
  belongs_to :deployment_workflow
  has_many :deployment_objects, :dependent => :destroy
  #has_and_belongs_to_many :deployment_triggers  # Triggers another deployment on success
  
  
  validates_uniqueness_of :name, :scope => :deployment_workflow_id
  validates_presence_of  :name
  validates_presence_of  :deploy_type
  
  
  safe_attributes 'name',
    'description',
    'type'
    

  
end