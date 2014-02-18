module Dradis
  # This class represents a Note category. Each Category has a name.
  class Category < ActiveRecord::Base
    # attr_accessible :name

    validates :name, presence: true
    before_destroy :valid_destroy

    private
    def valid_destroy
      if (self.id == 1)
        self.errors.add :base, 'Cannot delete Default category.'
      end
      if (Note.where(category_id: self.id) > 0)
        self.errors.add :base, 'Cannot delete Category with notes.'
      end
      return errors.count.zero? ? true : false
    end
  end
end