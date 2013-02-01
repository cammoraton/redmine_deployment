class DeploymentWorkflow < ActiveRecord::Base
  include Redmine::SafeAttributes
  
  unloadable
  
  belongs_to :project
  has_many :deployment_servers, :dependent => :destroy
  
  validates_uniqueness_of :order, :scope => :project_id
  validates_uniqueness_of :environment, :scope => :project_id
  
  safe_attributes 'environment',
    'order',
    'options'
  

  def move_up
    @workflow = DeploymentWorkflow.find_by_order(self.order - 1, :conditions => "project_id = #{self.project_id}")
    start_order = self.order
    if !@workflow.nil?
      self.order = 0
      self.save!
      @workflow.order = start_order
      @workflow.save!
    end
    self.order = start_order - 1
    self.save!
  end
  
  def move_down
    @workflow = DeploymentWorkflow.find_by_order(self.order + 1, :conditions => "project_id = #{self.project_id}")
    start_order = self.order
    if !@workflow.nil?
      self.order = 0
      self.save!
      @workflow.order = start_order
      @workflow.save!
    end
    self.order = start_order + 1
    self.save!
  end
  
  private
end
