class DeploymentTasksController < ApplicationController
  unloadable
  
  include DeploymentsHelper
  include DeploymentTasksHelper
  
  before_filter :find_project
  before_filter :find_environment
  before_filter :find_or_initialize_settings
  before_filter :find_target
  before_filter :authorize
  
  def new
    @task = DeploymentTask.new(params[:deployment_task])
    unless @task.task_type
      @task.task_type = "scm"
    end
    respond_to do |format|
      format.html { render :action => 'new' }
      format.js { render :partial => 'update_form' }
    end
  end
  
  def edit
    @task = DeploymentTask.find(params[:task_id])
    if params[:deployment_task]
      @task.attributes = params[:deployment_task]
    end
    respond_to do |format|
      format.html { render :action => 'edit' }
      format.js { render :partial => 'update_form' }
    end
  end
  
  def create
    @task = DeploymentTask.new(params[:deployment_task])
    @task.deployment_target = @target
    if @target.deployment_tasks.empty?
      @task.order = 1
    else
      @task.order = @target.deployment_tasks.last.order.to_i + 1
    end
    if @task.save
      redirect_to proc { url_for(:controller => 'deployments', :action => 'index', :id => @project, :tab => 'settings') }
    end
  end
  
  def update
    @task = DeploymentTask.find(params[:task_id])
    @task.attributes = params[:deployment_task]
    if @task.save
      redirect_to proc { url_for(:controller => 'deployments', :action => 'index', :id => @project, :tab => 'settings') }
    end
  end
  
  def delete
    @task = DeploymentTask.find(params[:task_id])
    @task.destroy
    redirect_to proc { url_for(:controller => 'deployments', :action => 'index', :id => @project, :tab => 'settings') }
  end
  
  def move_down
    @task = DeploymentTask.find(params[:task_id])
    @task.move_down
    redirect_to proc { url_for(:controller => 'deployments', :action => 'index', :id => @project, :tab => 'settings') }
  end
  
  def move_up
    @task = DeploymentTask.find(params[:task_id])
    @task.move_up
    redirect_to proc { url_for(:controller => 'deployments', :action => 'index', :id => @project, :tab => 'settings') }
  end
  
  private
  def find_project
 # @project variable must be set before calling the authorize filter
    @project = Project.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  def find_environment
    @environment = DeploymentEnvironment.find(params[:environment_id])
  rescue ActiveRecord::RecordNotFound
    render_404 
  end
  
  def find_target
    @target = DeploymentTarget.find(params[:target_id])
  rescue ActiveRecord::RecordNotFound
    render_404   
  end
end