class Node < ActiveRecord::Base
  acts_as_tree
  has_many :notes

  def to_json(options={})
    json = '{"text":"'
    json << self.label
    json << '"'
    if (self.children.any?)
      json << ', "children":'
      json << self.children.to_json
    else
      json << ',"leaf":true'
    end
    json << '}'
  end
end
