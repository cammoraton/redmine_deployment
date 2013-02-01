class CreateMilestones < ActiveRecord::Migration
  def self.up
    create_table :milestones do |t|
      t.string :name
      t.string :description
      t.string :status
      t.date :created_on
      t.date :updated_on
      t.date :planned_completion
      t.date :actual_completion
      t.integer :parent_id
      t.references :user
      t.references :project
      t.references :version
    end
  end
  
  def self.down
    drop_table :milestones
  end
end
