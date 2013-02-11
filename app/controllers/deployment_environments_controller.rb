class DeploymentEnvironmentsController < ApplicationController
  unloadable
  
  include DeploymentsHelper
  
  before_filter :find_project
  before_filter :find_or_initialize_settings
  before_filter :authorize
    
  def new
    @environment = DeploymentEnvironment.new
  end
  
  def create
    @environment = DeploymentEnvironment.new(params[:deployment_environment])
    @environment.project = @project
    @orders = DeploymentEnvironment.find_all_by_project_id(@project.id, :order => "\"deployment_environments\".\"order\"")
    if @orders.empty?
      @environment.order = 1
    else
      @environment.order = @orders.last.order.to_i + 1
    end
    @environment.save!
    redirect_to proc { url_for(:controller => 'deployments', :action => 'index', :id => @project, :tab => 'settings') }
  end
  
  def edit
    @environment = DeploymentEnvironment.find(params[:environment_id])
  end
  
  def update
    @environment = DeploymentEnvironment.find(params[:environment_id])
    @new_environment = DeploymentEnvironment.new(params[:deployment_environment])
    @environment.name = @new_environment.name
    @environment.description = @new_environment.description
    @environment.is_default = @new_environment.is_default
    @environment.valid_direct_target = @new_environment.valid_direct_target
    @environment.save
    redirect_to proc { url_for(:controller => 'deployments', :action => 'index', :id => @project, :tab => 'settings') }
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