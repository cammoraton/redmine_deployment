# We need to modify the versions model so it can have many milestones
module VersionPatch
  def self.included(base)
    base.class_eval do
      has_many :milestones
      has_many :deployments
    end
  end
end