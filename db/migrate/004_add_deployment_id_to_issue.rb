class AddDeploymentIdToIssue < ActiveRecord::Migration
  def self.up
    add_column :issues, :deployment_id, :integer
  end

  def self.down
    remove_column :issues, :deployment_id
  end
end