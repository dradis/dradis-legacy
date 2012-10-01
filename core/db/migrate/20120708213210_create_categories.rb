class CreateCategories < ActiveRecord::Migration
  def change
    create_table :dradis_categories do |t|
      t.string :name

      t.timestamps
    end
  end
end
