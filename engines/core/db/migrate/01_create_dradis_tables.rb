class CreateDradisTables < ActiveRecord::Migration

  def self.up
    create_table :dradis_categories do |t|
      t.string :name
      t.timestamps
    end

    create_table :dradis_notes do |t|
      t.string :author
      t.text :text
      t.integer :node_id
      t.integer :category_id
      t.timestamps
    end

    create_table :dradis_nodes do |t|
      t.string :label
      t.integer :type_id
      t.integer :parent_id
      t.integer :position
      t.timestamps
    end
  end

  def self.down
    drop_table :dradis_categories
    drop_table :dradis_notes
    drop_table :dradis_nodes
  end
end