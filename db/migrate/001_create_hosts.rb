class CreateHosts < ActiveRecord::Migration
  def self.up
    create_table :hosts do |t|
      t.column 'address', :string
    end
  end

  def self.down
    drop_table :hosts
  end
end
