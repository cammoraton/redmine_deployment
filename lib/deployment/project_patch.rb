module ProjectPatch
  def self.included(base)
    base.class_eval do
      has_many :deployment_environments, :dependent => :destroy
      has_many :deployment_targets, :through => :deployment_environments
      
      has_one  :deployment_setting, :dependent => :destroy
      
      has_one  :default_environment, :conditions => ["is_default = ?", true]
      has_one  :default_target, :through => :default_environment, :conditions => ["is_default = ?", true]
    end
  end
end