module ProjectPatch
  def self.included(base)
    base.class_eval do
      has_many :deployment_workflows, :dependent => :destroy
      
      def has_workflows?
        return true unless DeploymentWorkflow.find_all_by_project_id(self.id).empty?
        return false
      end
    end
  end
end