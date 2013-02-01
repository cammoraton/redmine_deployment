# We need to modify the issues model to allow it to associate with a milestone
module ChangesetPatch
  def self.included(base)
    base.class_eval do
      has_many :deployments, :dependent => :delete_all
    end
  end
end