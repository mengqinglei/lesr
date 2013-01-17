class CreateAds < ActiveRecord::Migration
  def change
    create_table :ads do |t|
      t.string :headline
      t.string :line1
      t.string :line2
      t.string :display_url
      t.string :google_ad_id
      t.string :destination_url
      t.integer :ad_group_id
      t.integer :campaign_id
      t.integer :account_id
      t.integer :account_group_id

      t.timestamps
    end
  end
end
