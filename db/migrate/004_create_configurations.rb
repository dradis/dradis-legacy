class CreateConfigurations < ActiveRecord::Migration
  def self.up
    create_table :configurations do |t|
      t.string :name
      t.string :value

      t.timestamps
    end
    Configuration.new(:name=>'revision', :value=>'0').save
    Configuration.new(:name=>'password', :value=>'dradis').save
    Configuration.new(:name=>'uploads_node', :value=>'Uploaded files').save
  end

  def self.down
    drop_table :configurations
  end
end
