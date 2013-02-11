module RepositoryControllerPatch
  def self.included(base)
    base.class_eval do
      before_filter :find_environments
      
      private
      def find_environments
        @environments = DeploymentEnvironment.find_all_by_project_id(@project.id, :order => "\"deployment_environments\".\"order\"")
      end
    end
  end
end
