class DeploymentServer < ActiveRecord::Base
  include Redmine::SafeAttributes
  unloadable
  
  DEPLOYMENT_TYPES = %w(scm cap dummy puppet)
  
  belongs_to :deployment_workflow
  has_many :deployments#, :dependent => :destroy  # This broke deletes if it was empty
  
  validates_uniqueness_of :name, :scope => :deployment_workflow_id
  validates_presence_of  :name
  validates_presence_of  :type
  
  
  safe_attributes 'name',
    'description',
    'type'
    

  
end