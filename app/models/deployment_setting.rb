class DeploymentSetting < ActiveRecord::Base
  include Redmine::SafeAttributes
  
  unloadable
  
  TRANSPORT_TYPES = %w(mcollective ssh)
  
  belongs_to :project

  validates_presence_of :project_id
  
end