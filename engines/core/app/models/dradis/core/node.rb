# Dradis Note objects are associated with a Node. It is possible to create a
# tree structure of Nodes to hierarchically structure the information held
# in the repository.
#
# Each Node has a :parent node and a :label. Nodes can also have many
# Attachment objects associated with them.
#

module Dradis
  module Core
    class Node < ActiveRecord::Base
      self.table_name = 'dradis_nodes'

      # Virtual attribute:
      #   * Set by the NotesController when modifying a note
      #   * Used by the RevisionObserver to track record changes
      attr_accessor :updated_by

      acts_as_tree
      has_many :notes, dependent: :destroy

      validates :label, presence: true

      before_destroy :destroy_attachments
      before_save do |record|
        record.type_id = Types::DEFAULT unless record.type_id
        record.position = 0 unless record.position
      end

      # Return all the Attachment objects associated with this Node.
      def attachments
        Attachment.find(:all, conditions: {node_id: self.id})
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
        METHODOLOGY = 2
        ISSUELIB = 3
      end
    end
  end
end