class Note < ActiveRecord::Base
  belongs_to :annotatable, :polymorphic => true
  belongs_to :category
  
  validates_presence_of :author, :text, :category
  def to_label
    return "note: #{category.name}/#{author}"
  end
end
