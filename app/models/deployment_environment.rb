class DeploymentEnvironment < ActiveRecord::Base
  include Redmine::SafeAttributes
  
  unloadable
  
  belongs_to :project
  has_many :deployment_targets, :dependent => :destroy
  has_many :deployment_tasks, :through => :deployment_targets
  has_many :deployment_objects, :through => :deployment_targets
  has_one  :deployment_setting, :through => :project
  
  has_one  :default_target, :conditions => ["\"deployment_targets\".\"is_default\" = ?", true], 
           :class_name => "DeploymentTarget", :foreign_key => "deployment_environment_id"

  validates_uniqueness_of :order, :scope => :project_id
  validates_uniqueness_of :name, :scope => :project_id
  
  validates_presence_of :order
  validates_presence_of :project_id
  
  before_save :fix_default
  before_destroy :fix_order
  
  safe_attributes 'name',
                  'description'

  # Sugar
  def valid_target?
    return false unless self.valid_direct_target
    has_valid_targets?
  end
  
  def is_default?
    self.is_default
  end
  
  # Are any of our targets valid?
  def has_valid_targets?
    self.deployment_targets.each do |target|
      return true unless target.is_dummy?
    end
    return false
  end
  
  def multiple_targets?
    return true if self.deployment_targets.count > 1
  end
  
  def free_targets?
    self.deployment_targets.each do |target|
      return true if target.free?
    end
    return false
  end
  
  def default_target
    self.deployment_targets.find_by_is_default(true)
  end
  
  # Move order up / down
  def move_up
    @environment = DeploymentEnvironment.find_by_order(self.order - 1, :conditions => "project_id = #{self.project_id}")
    start_order = self.order
    unless @environment.nil?
      self.order = 0
      self.save!
      @environment.order = start_order
      @environment.save!
    end
    self.order = start_order - 1
    self.save!
  end
  
  def move_down
    @environment = DeploymentEnvironment.find_by_order(self.order + 1, :conditions => "project_id = #{self.project_id}")
    start_order = self.order
    unless @environment.nil?
      self.order = 0
      self.save!
      @environment.order = start_order
      @environment.save!
    end
    self.order = start_order + 1
    self.save!
  end
  
  def can_promote(changeset_id)
     return false if changeset_id.nil?
     return false if ! self.free_targets?
     self.deployment_targets.each do |target|
       if target.last_deployment.nil?
         return true
       elsif target.last_deployment.changeset_id != changeset_id
         return true
       end
     end
     return false
  end
  
  private
  def fix_default
    if self.is_default
      self.project.deployment_environments.each do |env|
        if env.is_default? and env.id != self.id
          env.is_default = false
          env.save!
        end
      end
    end
  end
  
  def fix_order
    start_order = self.order
    self.order = 0
    self.save!
    self.project.deployment_environments.each do |env|
      if env.order >= start_order
        env.order = env.order - 1
        env.save!        
      end
    end
  end
end
