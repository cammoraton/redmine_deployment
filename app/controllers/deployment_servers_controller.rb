class DeploymentServersController < ApplicationController
  unloadable
  
  before_filter :find_workflow
  before_filter :find_project
  before_filter :authorize
  
  def new
    @server = DeploymentServer.new
  end
  
  def edit
    @server = DeploymentServer.find(params[:server_id])
  end
  
  def create
    @server = DeploymentServer.new(params[:deployment_server])
    @server.project_id = @project.id
    @server.deployment_workflow_id = @workflow.id
    @server.save!
    redirect_to proc { url_for(:controller => 'deployments', :action => 'index', :id => @project, :edit => true) }
  end
  
  def update
    
  end
  
  def delete
    @server = DeploymentServer.find(params[:server_id])
    @server.destroy
    redirect_to proc { url_for(:controller => 'deployments', :action => 'index', :id => @project, :edit => true) }
  end
  
  private
  def find_project
 # @project variable must be set before calling the authorize filter
    @project = Project.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  def find_workflow
    @workflow = DeploymentWorkflow.find(params[:workflow_id])
  rescue ActiveRecord::RecordNotFound
    render_404 
  end
end