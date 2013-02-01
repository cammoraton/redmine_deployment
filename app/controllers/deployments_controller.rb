class DeploymentsController < ApplicationController
  unloadable
  
  before_filter :find_workflows
  before_filter :find_project
  before_filter :authorize

  def new
  end

  def edit
  end

  def index
    if @workflow.empty?
      flash.now[:error] = t(:notice_no_targets, :url => url_for(:controller => 'deployment_workflows', :action => 'edit', :id => @project))
    end
  end

  def show
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
