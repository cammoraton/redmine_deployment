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
  
  # Dump the settings into yaml
  def settings_to_yaml
    settings = Hash.new
    settings[:defaults_to_head] = @settings.defaults_to_head
    settings[:can_promote_only] = @settings.can_promote_only
    settings[:approval_required] = @settings.approval_required
    settings[:atomize_tasks] = @settings.atomize_tasks
    settings[:remote_scm_path] = @settings.remote_scm_path
    settings[:deploy_path] = @settings.deploy_path
    settings[:transport_type] = @settings.transport_type
    settings[:repository_id] = @settings.repository_id
    settings[:environments] = Hash.new
    @environments.each do |env|
      settings[:environments][env.order] = Hash.new
      settings[:environments][env.order][:name] = env.name
      settings[:environments][env.order][:description] = env.description
      settings[:environments][env.order][:is_default] = env.is_default
      settings[:environments][env.order][:valid_direct_target] = env.valid_direct_target
      unless env.deployment_targets.empty?
        settings[:environments][env.order][:targets] = Hash.new
        env.deployment_targets.each do |target|
          settings[:environments][env.order][:targets][target.hostname] = Hash.new
          settings[:environments][env.order][:targets][target.hostname][:description] = target.description
          settings[:environments][env.order][:targets][target.hostname][:is_dummy] = target.is_dummy
          settings[:environments][env.order][:targets][target.hostname][:is_default] = target.is_default
          settings[:environments][env.order][:targets][target.hostname][:comments_required] = target.comments_required
          settings[:environments][env.order][:targets][target.hostname][:inherit_settings] = target.inherit_settings
          settings[:environments][env.order][:targets][target.hostname][:atomize_tasks] = target.atomize_tasks
          settings[:environments][env.order][:targets][target.hostname][:remote_scm_path] = target.remote_scm_path
          settings[:environments][env.order][:targets][target.hostname][:deploy_path] = target.deploy_path
          settings[:environments][env.order][:targets][target.hostname][:transport_type] = target.transport_type
          settings[:environments][env.order][:targets][target.hostname][:repository_id] = target.repository_id
          unless target.deployment_tasks.empty?
            settings[:environments][env.order][:targets][target.hostname][:tasks] = Hash.new
            target.deployment_tasks.each do |task|
              settings[:environments][env.order][:targets][target.hostname][:tasks][task.order] = Hash.new
              settings[:environments][env.order][:targets][target.hostname][:tasks][task.order][:label] = task.label
              settings[:environments][env.order][:targets][target.hostname][:tasks][task.order][:description] = task.description
              settings[:environments][env.order][:targets][target.hostname][:tasks][task.order][:task_type] = task.task_type
              settings[:environments][env.order][:targets][target.hostname][:tasks][task.order][:metadata] = task.metadata
              settings[:environments][env.order][:targets][target.hostname][:tasks][task.order][:continue_on_error] = task.continue_on_error
              settings[:environments][env.order][:targets][target.hostname][:tasks][task.order][:triggers_deployment] = task.triggers_deployment
              settings[:environments][env.order][:targets][target.hostname][:tasks][task.order][:trigger_id] = task.trigger_id
            end
          end
        end
      end  
    end
    
    settings.to_yaml
  end
  
  # Allow an import from yaml, restores, copies yada yada
  def settings_from_yaml(yaml)
    settings = YAML::load(yaml)
    
    @settings.defaults_to_head = settings[:defaults_to_head] 
    @settings.can_promote_only = settings[:can_promote_only] 
    @settings.approval_required = settings[:approval_required] 
    @settings.atomize_tasks = settings[:atomize_tasks]
    @settings.remote_scm_path = settings[:remote_scm_path]
    @settings.deploy_path = settings[:deploy_path]
    @settings.transport_type = settings[:transport_type]
    @settings.save
    settings[:environments].each_pair do |order, values|
      env = @project.deployment_environments.find_by_order(order)
      if current.nil?
        env = DeploymentEnvironment.new()
        env.order = order
        env.project_id = @project.id
      end
      env.name = values[:name]
      env.description = values[:description]
      env.is_default = values[:is_default] 
      env.valid_direct_target = values[:valid_direct_target]
      env.save
      values[:targets].each_pair do |hostname, data|
        target = env.deployment_targets.find_by_hostname(hostname)
        if target.nil?
          target = DeploymentTarget.new()
          target.hostname = hostname
          target.deployment_environment_id = env.id
        end
        target.description = data[:description]
        target.is_dummy = data[:is_dummy]
        target.is_default = data[:is_default]
        target.comments_required = data[:comments_required]
        target.inherit_settings = data[:inherit_settings]
        target.atomize_tasks = data[:atomize_tasks]
        target.remote_scm_path = data[:remote_scm_path]
        target.deploy_path = data[:deploy_path]
        target.transport_type = data[:transport_type]
        target.save
        data[:tasks].each_pair do |ord,task_values|
          task = target.deployment_tasks.find_by_order(ord)
          if task.nil?
            task = DeploymentTask.new()
            task.order = ord
            task.deployment_target_id = target.id
          end
          task.label = task_values[:label]
          task.description = task_values[:description]
          task.task_type = task_values[:task_type]
          task.metadata = task_values[:metadata]
          task.continue_on_error = task_values[:continue_on_error]
          task.triggers_deployment = task_values[:triggers_deployment]
          task.trigger_id = task_values[:trigger_id]
          task.save
        end
      end
    end
  end
end
