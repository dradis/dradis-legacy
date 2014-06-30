# An Issue represents a finding or a vulnerability. It holds information
# that is more or less static (what the problem is, how to fix it, CVE
# entries, external references, etc.).
#
# Every instance of an Issue, affects one Node, through the Evidence
# object:
#
# Node [1]>-----<[1] Evidence [n]>-----<[1] Instance
#

module Dradis
  module Core
    class Issue < Dradis::Core::Note

      before_validation do
        self.category = Category.issue unless self.category
      end

      has_many :evidence, dependent: :destroy
      has_many :affected, through: :evidence, source: :node

      # We don't do this any more because it would cascade a SQL query to fetch
      # evidence even when we're asking for other unrelated fields.
      # The only place where this was used was in the AdvancedWord export plugin.
      # def fields
      #   super.merge('Affected' => affected.uniq.collect(&:label).to_sentence)
      # end
      def title
        fields.fetch('Title', "This Issue doesn't provide a Title field")
      end
      def <=>(other)
        self.title <=> other.title
      end

      # This method groups all the available evidence associated with this Issue
      # into a Hash where the keys are the nodes. E.g.:
      # {
      #   <node 1> => [<evidence 1.1>, <evidence 1.2>],
      #   <node 2> => [<evidence 2.1>]
      # }
      #
      # This is useful in a number of views to present or hide information about
      # all the instances for a given issue and node/host.
      def evidence_by_node()
        results = Hash.new{|h,k| h[k] = [] }

        self.evidence.each do |evidence|
          results[evidence.node] << evidence
        end

        # This sorts nodes by IP address. Non-IPs appear first
        results.sort_by do |node,_|
          node.label.split('.').map(&:to_i)
        end
      end

      # Create a hash with all issues where the keys correspond to the field passed
      # as an argument
      def self.all_issues_by_field(field)
        # we don't memoize it because we want it to reflect recently added Issues
        issues_map = Issue.all.map do |issue|
          [issue.fields[field], issue]
        end
        Hash[issues_map]
      end
    end
  end
end