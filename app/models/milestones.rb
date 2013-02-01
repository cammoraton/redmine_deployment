class Milestones < ActiveRecord::Base
  unloadable
  
  belongs_to :project
  belongs_to :user
  belongs_to :version
  
  has_many :issues
end
