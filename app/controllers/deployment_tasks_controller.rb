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
  end
  
  def create
    @task = DeploymentTask.new(params[:deployment_task])
    @tasks = DeploymentTask.find_all_by_target_id(@target.id, :order => "\"deployment_tasks\".\"order\"")
    if @tasks.empty?
      @task.order = 1
    else
      @task.order = @tasks.last.order.to_i + 1
    end
    #@task.save!
    redirect_to proc { url_for(:controller => 'deployments', :action => 'index', :id => @project, :tab => 'settings') }
  end
  
  def update
    
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