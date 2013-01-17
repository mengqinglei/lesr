class CreateAdGroups < ActiveRecord::Migration
  def change
    create_table :ad_groups do |t|
      t.string :name
      t.integer :campaign_id
      t.integer :account_id
      t.integer :account_group_id

      t.timestamps
    end
  end
end
