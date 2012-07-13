
class Node < ActiveRecord::Base
  include ActsAsTree

  attr_accessible :label, :parent_id, :position, :type_id

  validates :label, :presence => true

  has_many :notes, :dependent => :destroy
  # has_many :attachments, :dependent => :destroy

  before_save {|record| record.position = 0 unless record.position }

  acts_as_tree order: :label

  module Types
    DEFAULT = 0
    HOST = 1
  end
end