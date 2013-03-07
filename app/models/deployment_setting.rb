class DeploymentSetting < ActiveRecord::Base
  include Redmine::SafeAttributes
  
  unloadable
  
  TRANSPORT_TYPES = %w(mcollective ssh)
  
  belongs_to :project

  validates_presence_of :project_id
  after_save :fix_descendents
  
  private
  def fix_descendents
    environments = self.project.deployment_environments
    unless environments.empty?
      environments.each do |environment|
        targets = environment.deployment_targets
        unless targets.empty?
          targets.each do |target|
            if target.inherits_settings?
              target.repository_id = self.repository_id
              unless target.is_dummy?
                target.remote_scm_path = self.remote_scm_path
                target.deploy_path = self.deploy_path
              end
              target.save!
            end
          end
        end
      end
    end
  end
end