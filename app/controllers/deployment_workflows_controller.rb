class DeploymentWorkflowsController < ApplicationController
  unloadable
  
  before_filter :find_project
  before_filter :authorize
    
  def new
    @workflow = DeploymentWorkflow.new
  end
  
  def create
    @workflow = DeploymentWorkflow.new(params[:deployment_workflow])
    @workflow.project = @project
    @orders = DeploymentWorkflow.find_all_by_project_id(@project.id, :order => "\"deployment_workflows\".\"order\"")
    if @orders.empty?
      @workflow.order = 1
    else 
      @workflow.order = @orders.last.order.to_i + 1
    end
    @workflow.save!
    redirect_to proc { url_for(:controller => 'deployments', :action => 'index', :id => @project, :edit => true) }
  end
  
  def delete
    @workflow = DeploymentWorkflow.find(params[:workflow_id]) 
    @workflow.destroy
    # Need to do order cleanup in delete method
    redirect_to proc { url_for(:controller => 'deployments', :action => 'index', :id => @project, :edit => true) }
  end 
  
  def move_down
    @workflow = DeploymentWorkflow.find(params[:workflow_id])
    @workflow.move_down
    redirect_to proc { url_for(:controller => 'deployments', :action => 'index', :id => @project, :edit => true) }
  end
  
  def move_up
    @workflow = DeploymentWorkflow.find(params[:workflow_id])
    @workflow.move_up
    redirect_to proc { url_for(:controller => 'deployments', :action => 'index', :id => @project, :edit => true) }
  end
  
  private
  def find_project
 # @project variable must be set before calling the authorize filter
    @project = Project.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end