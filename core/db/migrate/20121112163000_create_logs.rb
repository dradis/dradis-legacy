class CreateLogs < ActiveRecord::Migration
  def change
    create_table :dradis_logs do |t|
      t.integer :uid
      t.text :text

      t.timestamps
    end
  end
end
