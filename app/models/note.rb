class Note < ActiveRecord::Base
  belongs_to :category
  belongs_to :node

  def fields
    Hash[ *self.text.scan(/#\[(.+?)\]#\n(.*?)(?=#\[|\z)/m).flatten.collect do |str| str.strip end ]
  end
end
