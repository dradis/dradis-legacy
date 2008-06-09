class Node < ActiveRecord::Base
  acts_as_tree
  has_many :notes
end
