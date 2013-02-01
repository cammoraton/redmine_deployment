# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
RedmineApp::Application.routes.draw do
  match 'projects/:id/deploy/:action', :controller => 'deployments'
  match 'projects/:id/environments/:action', :controller => 'deployment_workflows'
  match 'projects/:id/environments/:workflow_id/servers/:action', :controller => 'deployment_servers'
end