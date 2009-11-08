# Dradis Note objects are associated with a Node. It is possible to create a 
# tree structure of Nodes to hierarchically structure the information held
# in the repository.
# 
# Each Node has a :parent node and a :label. Nodes can also have many 
# Attachment objects associated with them.
class Node < ActiveRecord::Base
  acts_as_tree
  has_many :notes

  # Return the JSON structure representing this Node and any child nodes
  # associated with it.
  def to_json(options={})
    json = '{"text":"'
    json << self.label
    json << '"'
    json << ',"id":"'
    json << self.attributes['id'].to_s
    json << '"'
    if (self.children.any?)
      json << ', "children":'
      json << self.children.to_json
    else
      #json << ',"leaf":true'
    end
    json << '}'
  end

  # Return all the Attachment objects associated with this Node.
  def attachments
    Attachment.find(:all, :conditions => {:node_id => self.id})
  end
end
