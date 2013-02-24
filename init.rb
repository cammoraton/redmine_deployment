require "redmine"

require_dependency 'deployment/changeset_patch'
require_dependency 'deployment/hooks'
require_dependency 'deployment/issue_patch'
require_dependency 'deployment/project_patch'
require_dependency 'deployment/repository_controller_patch'
require_dependency 'deployment/repository_patch'

require_dependency 'deployment/deploy_jobs'

Redmine::Plugin.register :deployment do
  name 'Deployment plugin'
  author 'Nick Cammorato'
  description 'This plugin provides a deployment framework'
  version '0.5'
  
  # Have only tested this on 2.2.x so if you want to try it
  # Just comment this out
  requires_redmine :version_or_higher => '2.2.0'

  # Add in the deployments menu
  menu :project_menu, :deployments, { :controller => :deployments, :action => :index }, :after => :roadmap, :param => :id, :caption => :label_deployment,
       :if => Proc.new { |p| p.module_enabled?(:deployment) }
  # Need to add in a check for if there are valid targets for the project.

  project_module :deployment do
    permission :view_deployments, { :deployments => [ :index, :show, :search ] }
    permission :manage_deployments, { :deployments => [ :index, :show, :search, :create ] }
    
    permission :deployment_administrator, { :deployments => [:index, :settings, :show, :search, :create ], 
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
Repository.send(:include, RepositoryPatch)
