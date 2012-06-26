# This class represents a Note category. Each Category has a name.
class Category < ActiveRecord::Base
  # Virtual attribute:
  #   * Set by the CategoriesController when modifying a category
  #   * Used by the RevisionObserver to track record changes
  attr_accessor :updated_by

  before_destroy :valid_destroy

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
