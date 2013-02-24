class DeploymentTask < ActiveRecord::Base
  include Redmine::SafeAttributes

  unloadable

  TASK_TYPES = %w(scm capistrano permissions notify verify trigger puppet)

  belongs_to :deployment_target
  
  serialize :metadata, Hash
    
  validates_uniqueness_of :order, :scope => :deployment_target_id
  validates_uniqueness_of :label, :scope => :deployment_target_id
  
  validates_presence_of :deployment_target_id
  validates_presence_of :label
  validates_presence_of :order
  validates_presence_of :task_type
  
  validates_presence_of :trigger_id, :if => :is_trigger?
  
  before_destroy :fix_order
  
  # Sugar
  def is_trigger?
    self.triggers_deployment
  end
  
  def continue_on_error?
    self.continue_on_error
  end
  
   # Move order up / down
  def move_up
    @task = DeploymentTask.find_by_order(self.order - 1, :conditions => "deployment_target_id = #{self.deployment_target_id}")
    start_order = self.order
    unless @task.nil?
      self.order = 0
      self.save!
      @task.order = start_order
      @task.save!
    end
    self.order = start_order - 1
    self.save!
  end
  
  def move_down
    @task = DeploymentTask.find_by_order(self.order + 1, :conditions => "deployment_target_id = #{self.deployment_target_id}")
    start_order = self.order
    unless @task.nil?
      self.order = 0
      self.save!
      @task.order = start_order
      @task.save!
    end
    self.order = start_order + 1
    self.save!
  end
  
  private
  def fix_order
    start_order = self.order
    self.order = 0
    self.save!
    self.deployment_target.deployment_tasks.each do |task|
      if task.order >= start_order
        task.order = task.order - 1
        task.save!        
      end
    end
  end
end