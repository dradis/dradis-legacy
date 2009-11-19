# Each item of the RSS feed has a corresponding Feed object associated with it.
class Feed < ActiveRecord::Base
  ValueAccessors = [:name, :title, :label, :text]

  # This item's title
  def title
    "#{self.resource.humanize} #{self.action}"
  end

  # The description of the item
  def description
    "#{self.value}"
  end

  # Who and when
  def stamp
    "by #{self.user} on #{self.updated_at.strftime("%d %B %Y at %H:%M:%S")}"
  end

  # Helper method to automagically fill in the item's attributes
  def self.extract_rss_value(record)
    ValueAccessors.each do |accessor|
      next unless record.respond_to? accessor
      return record.send accessor
    end
    return nil
  end

end
