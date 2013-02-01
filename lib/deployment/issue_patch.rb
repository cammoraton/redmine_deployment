require_dependency "issue"

# We need to modify the issues model to allow it to associate with a milestone
module IssuePatch
  def self.included(base)
    base.class_eval do
      belongs_to :milestone # Allow issues to be linked to milestones
      belongs_to :deployment # Allow issues to be linked to deployments
    end
  end
end