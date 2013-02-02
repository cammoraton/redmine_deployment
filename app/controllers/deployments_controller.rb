class DeploymentsController < ApplicationController
  unloadable
  
  before_filter :find_workflows
  before_filter :find_project
  before_filter :authorize

  def new
    if params[:deployment_object]
      @deployments = DeploymentObject.new(params[:deployment_object])
    else
      @deployment = DeploymentObject.new
      if params[:changeset_id]
        @deployment.changeset_id = params[:changeset_id]
      end
    end
  end

  def index
  end

  def show
    @deployment = DeploymentObject.find(params[:deployment_id])
  end
  
  def history
    if params[:server_id]
      @deployments = DeploymentObject.find_all_by_deployment_server_id(params[:server_id])
    elsif params[:workflow_id]
      @deployments = DeploymentWorkflow.find(params[:workflow_id]).deployment_objects
    else
      @deployments = DeploymentObject.find_all_by_project_id(@project.id)
    end
  end
  
  def promote
    redirect_to proc { url_for(:controller => 'deployments', :action => 'index', :id => @project) }
  end
  
  private

  def find_project
    # @project variable must be set before calling the authorize filter
    @project = Project.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  def find_workflows
    @workflow = DeploymentWorkflow.find_all_by_project_id(Project.find(params[:id]).id,  :order => "\"deployment_workflows\".\"order\"")
  rescue ActiveRecord::RecordNotFound
    render_404
  end 
end
