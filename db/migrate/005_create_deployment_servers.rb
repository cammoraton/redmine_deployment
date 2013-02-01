class CreateDeploymentServers < ActiveRecord::Migration
  def self.up
    create_table :deployment_servers do |t|
      t.string :name
      t.string :description
      t.string :type
      t.text :metadata
      t.references :deployment_workflow
      t.references :project
    end
  end
  
  def self.down
    drop_table :deployment_servers
  end
end