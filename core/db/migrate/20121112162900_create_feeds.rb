class CreateFeeds < ActiveRecord::Migration
  def change
    create_table :dradis_feeds do |t|
      t.string :action
      t.string :user
      t.datetime :actioned_at
      t.string :resource
      t.string :value

      t.timestamps
    end
  end
end
