class MilestonesController < ApplicationController
  unloadable

  def new
    @milestone = Milestone.new    
  end

  def edit
    @milestone = Milestone.find(params[:id])
    @project = @milestone.project
  end

  def show
  end
end
