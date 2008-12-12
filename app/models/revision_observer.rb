# 12/12/2008

# This class observes changes made to the Resources of the application and
# increses the revision number every time a change is made.
# TODO: create an RSS-like feed so users can be aware of the latest changes
class RevisionObserver < ActiveRecord::Observer
  observe :node, :note, :category

  def after_save(record)
    Configuration.increment_revision()
  end

  def after_destroy(record)
    Configuration.increment_revision()
  end
end
