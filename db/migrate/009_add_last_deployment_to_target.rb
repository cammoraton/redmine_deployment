class AddLastDeploymentToTarget < ActiveRecord::Migration
  def self.up
    add_column :deployment_targets, :last_deployment_id, :integer
  end

  def self.down
    remove_column :deployment_targets, :last_deployment_id
  end
end