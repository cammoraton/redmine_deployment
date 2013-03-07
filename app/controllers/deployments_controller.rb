class DeploymentsController < ApplicationController
  unloadable
  
  before_filter :find_project
  before_filter  :find_or_initialize_settings
  before_filter :authorize  
  
  include DeploymentsHelper

  def index
    @environments = @project.deployment_environments
    # Commence eager loading
    @environments.includes([{:deployment_targets => :deployment_tasks},   #Eagerly load tasks
                            {:deployment_targets => {:repository => { :latest_changeset => :issues }}},  #Eagerly load the repository
                            {:deployment_targets => :running_deployment}, #Eagerly load the running deployment(if any)
                            {:deployment_targets => {:last_deployment => { :changeset => :issues }}}]) #Eagerly load the last deployment and changeset
    @deployment = DeploymentObject.new()
    if @project.repository
      @project.repository.fetch_changesets if Setting.autofetch_changesets?
    end
  end

  # History / Search
  def search
    
  end

  # Settings
  def settings
    @settings = @project.deployment_setting
    @environments = @project.deployment_environments
    # Commence eager loading
    @environments.includes(:deployment_targets => :deployment_tasks) #Eagerly load deployment_targets and tasks
  end
  
  def update_settings
    @settings = @project.deployment_setting
    @settings.attributes = params[:deployment_setting]
    @settings.save
    redirect_to proc { url_for(:controller => 'deployments', :action => 'settings', :id => @project) }
  end
  
  # New Deployment
  def new
    @deployment = DeploymentObject.new() 
    if params[:changeset_id]
      @deployment.changeset_id = params[:changeset_id]
    end   
  end
  
  # Actually create a deployment
  def create
    @deployment = DeploymentObject.new(params[:deployment_object])
    @deployment.user_id = User.current.id
    if @deployment.save
      redirect_to proc { url_for(:controller => "deployments", :action => "index", :id => @project, :deploy_id => @deployment.id, :tab => "current") }
    end
  end
  
  # Show a past or current deployment
  def show
    @deployment = DeploymentObject.find(params[:deploy_id])
    respond_to do |format|
       format.js   { render :partial => 'deployments/common/update_progress' }
    end
  end 
  
  private
  def find_project
    # @project variable must be set before calling the authorize filter
    @project = Project.find(params[:id],
                            :include => [:deployment_environments,:deployment_setting])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
