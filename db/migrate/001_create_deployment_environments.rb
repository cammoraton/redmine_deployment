class CreateDeploymentEnvironments < ActiveRecord::Migration
  def self.up
    create_table :deployment_environments do |t|
      t.string  :name
      t.string  :description
      
      # Order for promotion purposes
      t.integer :order
      
      # Can you directly deploy to this?
      t.boolean :valid_direct_target, :default => false, :null => false
      # Default deployment environment?
      t.boolean :is_default, :default => false, :null => false
      
      t.references :project
    end
    # Create an index for projects/environments?
  end
  
  def self.down
    drop_table :deployment_environments
  end
end