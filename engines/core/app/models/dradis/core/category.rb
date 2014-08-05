module Dradis
  module Core
    # This class represents a Note category. Each Category has a name.
    class Category < ActiveRecord::Base
      self.table_name = 'dradis_categories'

      # Virtual attribute:
      #   * Set by the CategoriesController when modifying a category
      #   * Used by the RevisionObserver to track record changes
      attr_accessor :updated_by

      # -- Relationships --------------------------------------------------------

      # -- Callbacks ------------------------------------------------------------
      before_destroy :valid_destroy

      # -- Validations ----------------------------------------------------------

      # -- Scopes ---------------------------------------------------------------

      # -- Class Methods --------------------------------------------------------
      def self.default
        find_or_create_by(name: 'Default category')
      end

      def self.issue
        find_or_create_by(name: 'Issue description')
      end

      def self.properties
        find_or_create_by(name: 'Project properties')
      end

      def self.report
        find_or_create_by(name: 'Report category')
      end

      # -- Instance Methods -----------------------------------------------------

      private
      def valid_destroy
        if (self.id == 1)
          self.errors.add :base, 'Cannot delete Default category.'
        end
        if ( Note.count(:conditions =>{ :category_id => self.id }) > 0)
          self.errors.add :base, 'Cannot delete Category with notes.'
        end
        return errors.count.zero? ? true : false
      end
    end
  end
end