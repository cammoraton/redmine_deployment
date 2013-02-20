# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
RedmineApp::Application.routes.draw do
  match 'projects/:id/deploy/:action', :controller => 'deployments'
  match 'projects/:id/deploy/environment/:action', :controller => 'deployment_environments'
  match 'projects/:id/deploy/:environment_id/target/:action', :controller => 'deployment_targets'
  match 'projects/:id/deploy/:environment_id/target/task/:action', :controller => 'deployment_tasks'
end