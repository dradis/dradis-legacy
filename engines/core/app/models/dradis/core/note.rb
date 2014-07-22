# A Note in dradis is the basic unit of information. It has a :text and an
# :author field that capture the contents of the Note and the creator.
#
# In Dradis 2.x notes have a fixed set of fields (:text, :author, :category,
# :node). However, it is expected that in Dradis 3.x it will be possible to
# configure this list of fields to match the needs of the users.
#
# In the interim, Dradis 2.x Note objects use a special syntax in their :text
# field to define different fields. This syntax is as follows:
#
#   #[Title]#
#   Directory Listings
#
#   #[Description]#
#   Some directories on the server were configured [...]
#
# The syntax above would result in the call to the fields method to return a
# Hash with two elements:
#
#   {
#     'Title' => 'Directory Listings',
#     'Description' => 'Some directories on the server were configured [...]',
#   }
#
#
# This behaviour is extensively used by import/export plugins such as WordExport.
module Dradis
  module Core
    class Note < ActiveRecord::Base
      self.table_name = 'dradis_notes'

      include WithFields
      with_fields :text

      # Virtual attribute:
      #   * Set by the NotesController when modifying a note
      #   * Used by the RevisionObserver to track record changes
      attr_accessor :updated_by

      # -- Relationships --------------------------------------------------------
      belongs_to :category
      belongs_to :node

      # -- Callbacks ------------------------------------------------------------

      # -- Validations ----------------------------------------------------------
      validates :category, presence: true
      validates :node, presence: true

      # -- Scopes ---------------------------------------------------------------

      # -- Class Methods --------------------------------------------------------

      # -- Instance Methods -----------------------------------------------------

      # Used by .sort()
      def <=>(other)
        self.title <=> other.title
      end

      def title
        fields.fetch('Title', "This Note doesn't provide a Title field")
      end
    end
  end
end
