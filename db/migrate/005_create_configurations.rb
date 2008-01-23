class CreateConfigurations < ActiveRecord::Migration
  def self.up
    create_table :configurations do |t|
      t.column :name, :string
      t.column :value, :string
    end
    Configuration.new(:name=>'revision', :value=>'0').save
  end

  def self.down
    drop_table :configurations
  end
end
