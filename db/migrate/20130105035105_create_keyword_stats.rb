class CreateKeywordStats < ActiveRecord::Migration
  def change
    create_table :keyword_stats do |t|
      t.date :period
      t.string :name
      t.integer :impression
      t.integer :click
      t.float :cost
      t.integer :conversion
      t.float :position
      t.integer :ad_group_id
      t.integer :campaign_id
      t.integer :account_id
      t.integer :account_group_id

      t.timestamps
    end
  end
end
