class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.string :name

      t.timestamps
    end
    Category.new(:name=>'default category').save
  end

  def self.down
    drop_table :categories
  end
end
