class DeploymentEnvironmentsController < ApplicationController
  unloadable
  
  include DeploymentsHelper
  
  before_filter :find_project
  before_filter :find_or_initialize_settings
  before_filter :authorize
    
  def new
    @environment = DeploymentEnvironment.new
    if @project.deployment_environments.empty?
      @environment.is_default = true
    end
  end
  
  def create
    @environment = DeploymentEnvironment.new(params[:deployment_environment])
    @environment.project = @project
    if @project.deployment_environments.empty?
      @environment.order = 1
    else
      @environment.order = @project.deployment_environments.last.order.to_i + 1
    end
    @environment.save!
    redirect_to proc { url_for(:controller => 'deployments', :action => 'index', :id => @project, :tab => 'settings') }
  end
  
  def edit
    @environment = DeploymentEnvironment.find(params[:environment_id])
  end
  
  def update
    @environment = DeploymentEnvironment.find(params[:environment_id])
    @environment.attributes = params[:deployment_environment]
    if @environment.save
      redirect_to proc { url_for(:controller => 'deployments', :action => 'index', :id => @project, :tab => 'settings') }
    end
  end
  
  def delete
    @environment = DeploymentEnvironment.find(params[:environment_id])
    @environment.destroy
    # Need to do order cleanup in delete method
    redirect_to proc { url_for(:controller => 'deployments', :action => 'index', :id => @project, :tab => 'settings') }
  end
  
  def move_down
    @environment = DeploymentEnvironment.find(params[:environment_id])
    @environment.move_down
    redirect_to proc { url_for(:controller => 'deployments', :action => 'index', :id => @project, :tab => 'settings') }
  end
  
  def move_up
    @environment = DeploymentEnvironment.find(params[:environment_id])
    @environment.move_up
    redirect_to proc { url_for(:controller => 'deployments', :action => 'index', :id => @project, :tab => 'settings') }
  end
  
  private
  def find_project
 # @project variable must be set before calling the authorize filter
    @project = Project.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end