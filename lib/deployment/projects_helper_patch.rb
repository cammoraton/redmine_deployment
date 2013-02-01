module ProjectsHelperPatch
  def self.included(base)
    base.class_eval do
      def link_to_version(version, options = {})
        return '' unless version && version.is_a?(Version)
        link_to_if version.visible?, format_version_name(version), { :controller => 'versions', :action => 'show', :id => version }, options
      end
    end
  end
end
