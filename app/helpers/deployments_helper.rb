module DeploymentsHelper
  
  def deployment_tabs
    tabs = [{:name => 'current',  :action => :view_deployments,  :partial => 'deployments/current/index',  :label => :label_deploy_status},
            {:name => 'history',  :action => :view_deployments,  :partial => 'deployments/history/index',  :label => :label_deploy_history},
            {:name => 'settings', :action => :deployment_administrator, :partial => 'deployments/settings/index', :label => :label_deploy_settings}
           ]
    tabs.select {|tab| User.current.allowed_to?(tab[:action], @project)}
  end
  
  private
  def find_or_initialize_settings
    @settings = @project.deployment_setting ||= DeploymentSetting.new()
    if @settings.new_record?
      @settings.project_id = @project.id
      @settings.repository_id = @project.repository.id unless !@project.repository
    elsif !@settings.repository_id and @project.repository
      @settings.repository_id = @project.repository.id
    end
    @settings.save
  rescue ActiveRecord::RecordNotFound
    render_404 
  end
end
