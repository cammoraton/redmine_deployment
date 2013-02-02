require "redmine"

require_dependency 'deployment/changeset_patch'
require_dependency 'deployment/hooks'
require_dependency 'deployment/issue_patch'
require_dependency 'deployment/version_patch'
require_dependency 'deployment/project_patch'
require_dependency 'deployment/projects_helper_patch'
require_dependency 'deployment/projects_controller_patch'
require_dependency 'deployment/repository_controller_patch'

require_dependency 'deployment/deploy_jobs'

Redmine::Plugin.register :deployment do
  name 'TERC Deployment plugin'
  author 'Nick Cammorato'
  description 'This plugin provides a deployment framework'
  version '0.0.1'
    
  requires_redmine :version_or_higher => '2.2.1'
  
  # UI Change.  By default roadmap doesn't show up unless a version has been added via settings
  # This is incredibly counter-intuitive, so we fix it.
  
  # Delete roadmap so we can readd it
  delete_menu_item :project_menu, :roadmap  # Without this we'd have to patch lib/redmine.rb
 
  # Readd roadmap - keep the default behavior of needing versions defined before display but also display
  # if this module is enabled and the user is allowed to manage versions
  menu :project_menu, :roadmap, { :controller => 'versions', :action => 'index' }, :after => :activity, :param => :project_id,
        :if => Proc.new { |p| p.shared_versions.any? or p.module_enabled?(:deployment) }
  # Add in the deployments menu
  menu :project_menu, :deployments, { :controller => :deployments, :action => :index }, :after => :roadmap, :param => :id, :caption => :label_deploy,
        :if => Proc.new { |p| p.module_enabled?(:deployment) and ((p.has_workflows? and (User.current.allowed_to?(:view_deployments, p) or User.current.allowed_to?(:manage_deployments, p))) or User.current.allowed_to?(:manage_deployment_targets,p)) }
  # Need to add in a check for if there are valid targets for the project.

  project_module :deployment do
    permission :view_deployments, { :deployments => [ :show,:index,:history ] }
    permission :manage_deployments, { :deployments => [ :show,:index,:edit,:new,:update,:create,:promote,:history ] }
    
    permission :manage_deployment_targets, { :deployments => [ :show,:index,:edit,:new,:update,:create,:promote,:history ], :deployment_workflows => [ :move_up,:move_down,:create,:new,:delete ], :deployment_servers => [:new,:edit,:update,:create,:delete] }
  end
end

# Monkeypatch!
Changeset.send(:include, ChangesetPatch)
Issue.send(:include, IssuePatch)  # We need to modify the issues model to allow it to associate with a milestone
Version.send(:include, VersionPatch) # And versions as well
Project.send(:include, ProjectPatch) # Projects need to be able to see deployment workflows
ProjectsHelper.send(:include, ProjectsHelperPatch) # And we need to make some modifications to the default projects helper as well
ProjectsController.send(:include, ProjectsControllerPatch)
RepositoriesController.send(:include, RepositoryControllerPatch) # Add in the find_workflow before_filter
