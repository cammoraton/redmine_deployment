class CreateDeploymentTasks < ActiveRecord::Migration
  def self.up
    create_table :deployment_tasks do |t|
      t.string  :label
      t.string  :description
      t.integer :order
      t.string  :task_type # Type of Task
      t.float   :progress, :default => 0, :null => 0  # Amount to increment progress by
      t.text    :metadata  # Big ol mess of hash data to avoid having to muck with the DB
      
      # Options
      # Continue on error?
      t.boolean :continue_on_error, :default => false, :null => false
      # Do we trigger another deployment?
      t.boolean :triggers_deployment, :default => false, :null => false
      t.integer :trigger_id

      t.references :deployment_target
    end
  end
  
  def self.down
    drop_table :deployment_tasks
  end
end