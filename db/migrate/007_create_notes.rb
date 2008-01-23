class CreateNotes < ActiveRecord::Migration
  def self.up
    create_table :notes do |t|
      t.column 'author', :string
      t.column 'category_id', :integer
      t.column 'text', :text
      t.column 'annotatable_id', :integer
      t.column 'annotatable_type', :string
    end
  end

  def self.down
    drop_table :notes
  end
end
