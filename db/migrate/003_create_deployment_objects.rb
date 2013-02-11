class CreateDeploymentObjects < ActiveRecord::Migration
  def self.up
    create_table :deployment_objects do |t|
      t.string :comment
      t.string :status
      t.float  :progress, :default => 0.0, :null => 0.0
      
      t.boolean :approved, :default => false, :null => false
      
      t.timestamp :created_on
      t.timestamp :updated_on
      
      t.text :log
      
      t.references :user
      t.references :issue
      
      t.references :changeset
      
      t.references :deployment_target
      t.references :delayed_job
    end
  end
  def self.down
    drop_table :deployment_objects
  end
end
