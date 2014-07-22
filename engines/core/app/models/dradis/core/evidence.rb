# Evidence is what describes each specific instance of an Issue. It ties the
# general problem description represented by the Issue (e.g. what SQL injection)
# is, with the details specific to this case (e.g. for host X, and URL Y, and
# parameter Z).
#
# Each Evidence ties 1 Issue with 1 Node.
#

module Dradis
  module Core
    class Evidence < ActiveRecord::Base
      self.table_name = 'dradis_evidence'

      include WithFields
      with_fields :content

      # Virtual attribute:
      #   * Set by the EvidenceController when modifying a note
      #   * Used by the RevisionObserver to track record changes
      attr_accessor :updated_by

      # -- Relationships --------------------------------------------------------
      belongs_to :issue
      belongs_to :node

      # -- Callbacks ------------------------------------------------------------

      # -- Validations ----------------------------------------------------------
      validates :issue, presence: true, associated: true
      validates :node, presence: true, associated: true

      # -- Scopes ---------------------------------------------------------------

      # -- Class Methods --------------------------------------------------------

      # -- Instance Methods -----------------------------------------------------

      # Used by .sort()
      def <=>(other)
        self.issue.title <=> other.issue.title
      end


      private

      # See WithFields concern
      def local_fields
        {'Label' => node.label}
      end
    end
  end
end