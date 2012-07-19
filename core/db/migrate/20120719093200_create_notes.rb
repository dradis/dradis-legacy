class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.string :author
      t.text :text
      t.integer :node_id
      t.integer :category_id

      t.timestamps
    end
  end
end
