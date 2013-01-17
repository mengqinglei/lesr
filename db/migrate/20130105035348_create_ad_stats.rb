class CreateAdStats < ActiveRecord::Migration
  def change
    create_table :ad_stats do |t|
      t.date :period
      t.integer :impression
      t.integer :click
      t.float :cost
      t.integer :conversion
      t.integer :ad_id
      t.integer :ad_group_id
      t.integer :campaign_id
      t.integer :account_id
      t.integer :account_group_id

      t.timestamps
    end
  end
end
