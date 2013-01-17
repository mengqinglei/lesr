class CreateCampaigns < ActiveRecord::Migration
  def change
    create_table :campaigns do |t|
      t.string :name
      t.integer :account_id
      t.integer :account_group_id

      t.timestamps
    end
  end
end
