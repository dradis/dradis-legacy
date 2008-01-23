class CreateServices < ActiveRecord::Migration
  def self.up
    create_table :services do |t|
      t.column 'name', :string
      t.column 'host_id', :integer
      t.column 'port', :integer
      t.column 'protocol_id', :integer, :null => false
    end
  end

  def self.down
    drop_table :services
  end
end
