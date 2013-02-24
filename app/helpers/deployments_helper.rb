require 'yaml'

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
  
  # Convert the settings, targets, tasks into yaml
  # To allow backups and easy copying
  def settings_to_yaml
    settings = Hash.new
    
    settings[:environments] = Hash.new
    @environments.each do |env|
      settings[:environments][env.order] = Hash.new
      unless env.deployment_targets.empty?
        settings[:environments][env.order][:targets] = Hash.new
        env.deployment_targets.each do |target|
          settings[:environments][env.name][:targets][target.hostname] = Hash.new
          unless target.deployment_tasks.empty?
            settings[:environments][env.name][:targets][target.hostname][:tasks] = Hash.new
            target.deployment_tasks.each do |task|
              settings[:environments][env.name][:targets][target.hostname][:tasks][task.order] = Hash.new
            end
          end
        end
      end  
    end
    
    settings.to_yaml
  end
  
  # Allow an import from yaml, restores, copies yada yada
  def settings_from_yaml(yaml)
    
  end
end
