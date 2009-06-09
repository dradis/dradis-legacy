class Note < ActiveRecord::Base
  belongs_to :category
  belongs_to :node

  def fields
    begin
      Hash[ *self.text.scan(/#\[(.+?)\]#[\r|\n](.*?)(?=#\[|\z)/m).flatten.collect do |str| str.strip end ]
    rescue
      # if the note is not in the expected format, just return an empty hash
      {}
    end
  end
end
