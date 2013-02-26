module RepositoryPatch
  def self.included(base)
    base.class_eval do
      before_destroy :clear_deployments
      
      private
      def clear_deployments
        targets  = DeploymentTarget.find_all_by_repository_id(self.id)
        unless targets.nil? or targets.empty?         
          targets.each do |target|
            target.repository_id = nil
            target.save!
          end
        end
        settings = self.project.deployment_setting
        unless settings.nil?
          if settings.repository_id == self.id
            settings.repository_id = nil
            settings.save!
          end
        end
      end
    end
  end
end