
# This file holds some functionality that hasn't been migrated to dradis_core yet.

class Node < ActiveRecord::Base
  # Virtual attribute:
  #   * Set by the NotesController when modifying a note
  #   * Used by the RevisionObserver to track record changes
  attr_accessor :updated_by

  before_destroy :destroy_attachments
  before_save {|record| record.position = 0 unless record.position }


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
