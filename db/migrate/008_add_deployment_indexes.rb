# Add in some Indexes to improve query times
class AddDeploymentIndexes < ActiveRecord::Migration
  def self.up
    add_index :deployment_objects,      :project_id
    add_index :deployment_environments, :project_id
    add_index :deployment_environments, :order
    add_index :deployment_targets,      :deployment_environment_id
    add_index :deployment_targets,      :is_dummy
    add_index :deployment_tasks,        :deployment_target_id
    add_index :deployment_tasks,        :order
    add_index :deployment_objects,      :deployment_target_id
    add_index :deployment_objects,      :status
  end

  def self.down
    remove_index :deployment_objects,      :project_id
    remove_index :deployment_environments, :project_id
    remove_index :deployment_environments, :order
    remove_index :deployment_targets,      :deployment_environment_id
    remove_index :deployment_targets,      :is_dummy
    remove_index :deployment_tasks,        :deployment_target_id
    remove_index :deployment_tasks,        :order
    remove_index :deployment_objects,      :deployment_target_id
    remove_index :deployment_objects,      :status
  end
end