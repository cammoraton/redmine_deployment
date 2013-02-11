class CreateDeploymentSettings < ActiveRecord::Migration
  def self.up
    create_table :deployment_settings do |t|
      t.boolean    :defaults_to_head, :default => true, :null => false
      t.boolean    :can_promote_only, :default => false, :null => false
      t.boolean    :approval_required,  :default => false, :null => false
      
      t.string     :remote_scm_path
      t.string     :deploy_path
      
      t.integer    :repository_id
      t.references :project
    end
    # Create an index for projects/environments?
  end
  
  def self.down
    drop_table :deployment_settings
  end
end