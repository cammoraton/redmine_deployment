class DeploymentEnvironment < ActiveRecord::Base
  include Redmine::SafeAttributes
  
  unloadable
  
  belongs_to :project
  has_many :deployment_targets, :dependent => :destroy
  has_many :deployment_objects, :through => :deployment_targets
  has_one  :deployment_setting, :through => :project
  #before_delete :fix_order
  #Need to do an is_default fix
  
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
  
  def next
    return nil unless self.order > 1
    DeploymentEnvironment.find_by_order(self.order - 1, :conditions => "project_id = #{self.project_id}")
  end
  
  private
  def fix_default
    if self.is_default
      self.project.deployment_environments.each do |env|
        if env.is_default?
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
