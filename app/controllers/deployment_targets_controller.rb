class DeploymentTargetsController < ApplicationController
  unloadable
  
  include DeploymentsHelper
   
  before_filter :find_project
  before_filter :find_environment
  before_filter :find_or_initialize_settings
  before_filter :authorize
  
  def new
    @target = DeploymentTarget.new
    @target.repository_id = @settings.repository_id
    if @environment.deployment_targets.empty?
      @target.is_default = true
    end
  end
  
  def edit
    @target = DeploymentTarget.find(params[:target_id])
  end
  
  def create
    @target = DeploymentTarget.new(params[:deployment_target])
    @target.deployment_environment_id = @environment.id
    if @target.inherit_settings
      @target.repository_id = @settings.repository_id
    end
    if @target.save
      redirect_to proc { url_for(:controller => 'deployments', :action => 'index', :id => @project, :tab => 'settings') }
    end
  end
  
  def update
    @target = DeploymentTarget.find(params[:target_id])
    @target.attributes = params[:deployment_target]
    if @target.save
      redirect_to proc { url_for(:controller => 'deployments', :action => 'index', :id => @project, :tab => 'settings') }
    end
  end
  
  def delete
    @target = DeploymentTarget.find(params[:target_id])
    @target.destroy
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
end