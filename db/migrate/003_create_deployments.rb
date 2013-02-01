class CreateDeployments < ActiveRecord::Migration
  def self.up
    create_table :deployments do |t|
      t.string :description
      t.string :status
      t.date :deployed_on
      t.text :log
      t.references :project
      t.references :version
      t.references :user
      t.references :issue
      t.references :milestone
      t.references :changeset
      t.references :deployment_server
      t.references :delayed_job
    end
  end
  def self.down
    drop_table :deployments
  end
end
