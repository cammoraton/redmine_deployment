class CreateDeploymentTargets < ActiveRecord::Migration
  def self.up
    create_table :deployment_targets do |t|
      t.string :hostname
      t.string :description
      
      # Options
      # Dummy boolean, if true then is a pointer to a repository
      t.boolean :is_dummy, :default => false, :null => false
      # Default target for environment?
      t.boolean :is_default, :default => false, :null => false
      # Enforce commenting?
      t.boolean :comments_required, :default => true, :null => true
      # Inherit global settings
      t.boolean :inherit_settings, :default => true, :null => true

      # We belong to an environment
      t.references :deployment_environment      
      
      # We may override global settings
      t.string :remote_scm_path
      t.string :deploy_path
      
      # We MAY reference a repository
      t.references :repository
    end
  end
  
  def self.down
    drop_table :deployment_targets
  end
end