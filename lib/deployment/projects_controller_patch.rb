module ProjectsControllerPatch
  def self.included(base)
    base.class_eval do
      before_filter :find_workflows
      
      private
      def find_workflows
        @workflow = DeploymentWorkflow.find_all_by_project_id(params[:id], :order => "'order'")
      end
    end
  end
end