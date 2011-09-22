# This class observes changes made to the Resources of the application and
# increses the revision number every time a change is made.
#-- TODO: create an RSS-like feed so users can be aware of the latest changes
class RevisionObserver < ActiveRecord::Observer
  observe :node, :note, :category


  # Log the observed change so the Ajax poller can update the browser widgets
  # with the relevant info. See LogsController#index
  def log_change(action, record)
    data = {
      :action => action,
      :resource => record.class.to_s.downcase,
      :record => record.attributes,
      :by => record.updated_by
    }
    Log.create(:uid => 0, :text => data.to_yaml )
  end

  # This method is called every time an object of the observed classes is saved.
  def after_create(record)
    Configuration.increment_revision()
    Feed.create(:action => 'created',
      :actioned_at => record.updated_at,
      :resource => record.class.to_s.downcase,
      :value => Feed.extract_rss_value(record))
    log_change('create', record)
  end

  # This method is called every time an object of the observed classes is saved.
  def after_update(record)
    Configuration.increment_revision()
    Feed.create(:action => 'updated',
      :actioned_at => record.updated_at,
      :resource => record.class.to_s.downcase,
      :value => Feed.extract_rss_value(record))
    log_change('update', record)
  end

  # This method is called every time an object of the observed classes is deleted.
  def after_destroy(record)
    Configuration.increment_revision()
    Feed.create(:action => 'deleted',
      :actioned_at => record.updated_at,
      :resource => record.class.to_s.downcase,
      :value => Feed.extract_rss_value(record))
    log_change('destroy', record)
  end
end
