require "redmine"

require_dependency 'deployment/changeset_patch'
require_dependency 'deployment/hooks'
require_dependency 'deployment/issue_patch'
require_dependency 'deployment/project_patch'
require_dependency 'deployment/repository_controller_patch'

require_dependency 'deployment/deploy_jobs'

Redmine::Plugin.register :deployment do
  name 'TERC Deployment plugin'
  author 'Nick Cammorato'
  description 'This plugin provides a deployment framework'
  version '0.1.0'
    
  requires_redmine :version_or_higher => '2.2.1'

  # Add in the deployments menu
  menu :project_menu, :deployments, { :controller => :deployments, :action => :index }, :after => :roadmap, :param => :id, :caption => :label_deployment
        #,:if => Proc.new { |p| p.module_enabled?(:deployment) and ((User.current.allowed_to?(:view_deployments, p) or User.current.allowed_to?(:manage_deployments, p)) or User.current.allowed_to?(:manage_deployment_targets,p)) }
  # Need to add in a check for if there are valid targets for the project.

  project_module :deployment do
    permission :view_deployments, { :deployments => [ :index ] }
    permission :manage_deployments, { :deployments => [ :index ] }
    
    permission :manage_deployment_settings, { :deployments => [:index, :settings], 
                                              :deployment_environments => [:new,:create,:move_up,:move_down,:edit,:update,:delete], 
                                              :deployment_targets => [:new,:create,:edit,:update,:delete ],
                                              :deployment_tasks => [:new,:create, :edit, :update, :delete, :move_up, :move_down] }
  end
end

# Monkeypatch!
Changeset.send(:include, ChangesetPatch)
Issue.send(:include, IssuePatch)  # We need to modify the issues model to allow it to associate with a deployment
Project.send(:include, ProjectPatch) # Projects need to be able to see deployment workflows
RepositoriesController.send(:include, RepositoryControllerPatch) # Add in the find_workflow before_filter
