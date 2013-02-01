class CreateDeploymentWorkflows < ActiveRecord::Migration
  def self.up
    create_table :deployment_workflows do |t|
      t.string :environment
      t.integer :order
      t.string :options
      
      t.references :project
      t.references :repository
    end
  end
  
  def self.down
    drop_table :deployment_workflows
  end
end