class Feed < ActiveRecord::Base

  ValueAccessors = [:name, :title, :label, :text]

  def title
    "#{self.action.humanize} a #{self.resource} on #{self.actioned_at.strftime("%Y-%m-%d %H:%M:%S")}"
  end

  def description
    "#{self.value}"
  end

  def self.extract_rss_value(record)
    ValueAccessors.each do |accessor|
      next unless record.respond_to? accessor
      return record.send accessor
    end
    return nil
  end

end
