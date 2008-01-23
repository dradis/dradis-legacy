class CreateTickets < ActiveRecord::Migration
  def self.up
    create_table :tickets do |t|
      t.column 'value', :string
      t.column 'ip', :string
      t.column 'valid_until', :timestamp
    end
  end

  def self.down
    drop_table :tickets
  end
end
