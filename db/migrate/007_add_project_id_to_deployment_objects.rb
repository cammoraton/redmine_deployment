# Improve indexing and a few other things.
class AddProjectIdToDeploymentObjects < ActiveRecord::Migration
  def self.up
    add_column :deployment_objects, :project_id, :integer
  end

  def self.down
    remove_column :deployment_objects, :project_id
  end
end