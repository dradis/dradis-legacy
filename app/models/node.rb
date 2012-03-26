# Dradis Note objects are associated with a Node. It is possible to create a 
# tree structure of Nodes to hierarchically structure the information held
# in the repository.
# 
# Each Node has a :parent node and a :label. Nodes can also have many 
# Attachment objects associated with them.
class Node < ActiveRecord::Base
  attr_accessible :label, :parent_id, :position, :type_id

  # Virtual attribute:
  #   * Set by the NotesController when modifying a note
  #   * Used by the RevisionObserver to track record changes
  attr_accessor :updated_by

  acts_as_tree
  validates_presence_of :label
  has_many :notes, :dependent => :destroy

  before_destroy :destroy_attachments
  before_save {|record| record.position = 0 unless record.position }

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

  module Types
    DEFAULT = 0
    HOST = 1
  end
end
