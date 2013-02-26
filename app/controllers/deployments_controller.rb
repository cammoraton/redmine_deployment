class DeploymentsController < ApplicationController
  unloadable
  

  before_filter :find_project
  before_filter :find_environments
  before_filter :find_or_initialize_settings
  before_filter :authorize

  include DeploymentsHelper
  
  def index
    @deployment = DeploymentObject.new()
    if @project.repository
      @project.repository.fetch_changesets if Setting.autofetch_changesets?
    end
  end
  
  def create
    @deployment = DeploymentObject.new(params[:deployment_object])
    @deployment.user_id = User.current.id
    if @deployment.save
      redirect_to proc { url_for(:controller => "deployments", :action => "index", :id => @project, :deploy_id => @deployment.id, :tab => "current") }
    end
  end
 
  def new
    @deployment = DeploymentObject.new() 
    if params[:changeset_id]
      @deployment.changeset_id = params[:changeset_id]
    end   
  end

  def show
    respond_to do |format|
       format.js   { render :partial => 'update_progress' }
    end
  end
  
  def search
    @deployments = DeploymentObject.find_all_by_project_id(@project.id)
    respond_to do |format|
       format.js   { render :partial => 'search_results' }
    end
  end
  
  def settings
    unless !params[:deployment_setting]
      @settings = @project.deployment_setting
      @settings.attributes = params[:deployment_setting]
      @settings.save
    end
    redirect_to proc{ url_for(:controller => 'deployments', :action => 'index', :id => @project, :tab => 'settings')}
  end
  
  private
  def find_project
    # @project variable must be set before calling the authorize filter
    @project = Project.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  def find_environments
    @environments = DeploymentEnvironment.find_all_by_project_id(@project.id, :order => "\"deployment_environments\".\"order\"")
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  def find_or_initialize_settings
    @settings = @project.deployment_setting ||= DeploymentSetting.new()
    if @settings.new_record?
      @settings.project_id = @project.id
      @settings.repository_id = @project.repository.id unless !@project.repository
    elsif !@settings.repository_id and @project.repository
      @settings.repository_id = @project.repository.id
    end
    @settings.save
  rescue ActiveRecord::RecordNotFound
    render_404 
  end
end
