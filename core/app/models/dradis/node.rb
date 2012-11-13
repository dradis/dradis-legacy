module Dradis
  class Node < ActiveRecord::Base
    include ActsAsTree

    attr_accessible :label, :parent_id, :position, :type_id

    validates :label, presence: true

    has_many :notes, dependent: :destroy
    # has_many :attachments, :dependent => :destroy

    before_save {|record| record.position = 0 unless record.position }

    acts_as_tree order: :label

    module Types
      DEFAULT = 0
      HOST = 1
    end

    # ExtJS specific!
    # Return the JSON structure representing this Node and any child nodes
    # associated with it.
    def as_json(options={})
      json = {
        :text => self.label,
        :id => self.attributes['id'],
        :type => self.type_id || 0,
        :position => self.position || 0,
        :parent_id => self.parent_id
      }
      if (self.children.any?)
        json[:children] = self.children.sort{|a,b| (a.position||0) <=> (b.position||0) }
      end
      return json
    end

  end
end