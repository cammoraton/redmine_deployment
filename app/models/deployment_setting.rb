class DeploymentSetting < ActiveRecord::Base
  include Redmine::SafeAttributes
  
  unloadable
  
  belongs_to :project

  validates_presence_of :project_id
  
end