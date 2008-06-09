class Note < ActiveRecord::Base
  belongs_to :category
  belongs_to :node
end
