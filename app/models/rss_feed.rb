class RssFeed < ActiveRecord::Base

  def title
    "#{self.action.humanize} a #{self.resource} on #{self.actioned_at.strftime("%Y-%m-%d %H:%M:%S")}"
  end

end
