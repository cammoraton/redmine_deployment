module ProjectPatch
  def self.included(base)
    base.class_eval do
      has_many :deployment_environments, :order => "\"#{DeploymentEnvironment.table_name}\".\"order\"", :dependent => :destroy
      has_many :deployment_targets, :through => :deployment_environments
      has_many :deployment_objects, :order => "#{DeploymentObject.table_name}.created_on DESC"
      
      has_one  :deployment_setting, :dependent => :destroy
      
      has_one  :default_environment, :conditions => ["\"deployment_environments\".\"is_default\" = ?", true], :class_name => "DeploymentEnvironment",
               :foreign_key => "project_id"
      has_one  :default_target, :through => :default_environment
    end
  end
end