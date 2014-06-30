class CreateDradisTables < ActiveRecord::Migration

  def self.up
    create_table :dradis_categories do |t|
      t.string :name
      t.timestamps
    end

    create_table :dradis_configurations do |t|
      t.string :name
      t.string :value
      t.timestamps
    end

    create_table :dradis_notes do |t|
      t.string :author
      t.text :text
      t.references :node
      t.references :category
      t.timestamps
    end

    create_table :dradis_nodes do |t|
      t.string :label
      t.integer :type_id
      # This is a self-reference to build the tree structure
      t.integer :parent_id
      t.integer :position
      t.timestamps
    end

    create_table :evidence do |t|
      t.references :node
      t.references :issue
      t.text :content
      t.string :author

      t.timestamps
    end
  end

  def self.down
    drop_table :dradis_evidence
    drop_table :dradis_notes
    drop_table :dradis_categories
    drop_table :dradis_nodes
    drop_table :configurations
  end
end