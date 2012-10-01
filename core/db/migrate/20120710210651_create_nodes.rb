class CreateNodes < ActiveRecord::Migration
  def change
    create_table :dradis_nodes do |t|
      t.string :label
      t.integer :type_id
      t.integer :parent_id
      t.integer :position

      t.timestamps
    end
  end
end
