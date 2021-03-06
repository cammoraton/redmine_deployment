# Allow Issues to be linked to deployment objects
class AddDeploymentIdToIssue < ActiveRecord::Migration
  def self.up
    add_column :issues, :deployment_object_id, :integer
  end

  def self.down
    remove_column :issues, :deployment_object_id
  end
end