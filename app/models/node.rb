# Dradis Note objects are associated with a Node. It is possible to create a 
# tree structure of Nodes to hierarchically structure the information held
# in the repository.
# 
# Each Node has a :parent node and a :label. Nodes can also have many 
# Attachment objects associated with them.
class Node < ActiveRecord::Base
  before_destroy :destroy_attachments
  acts_as_tree
  validates_presence_of :label
  has_many :notes, :dependent => :destroy

  # Return the JSON structure representing this Node and any child nodes
  # associated with it.
  def as_json(options={})
    json = { :text => self.label, :id => self.attributes['id'], :type => self.type_id || 0 }
    if (self.children.any?)
      json[:children] = self.children
    end
    return json
  end

  # Return all the Attachment objects associated with this Node.
  def attachments
    Attachment.find(:all, :conditions => {:node_id => self.id})
  end

  private
  # Whenever a node is deleted all the associated attachments have to be 
  # deleted too
  def destroy_attachments
    attachments_dir = Attachment.pwd.join(self.id.to_s)
    FileUtils.rm_rf attachments_dir if File.exists?(attachments_dir)
  end
end
