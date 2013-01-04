class CreateAccountGroups < ActiveRecord::Migration
  def change
    create_table :account_groups do |t|
      t.string :name
      t.integer :agency_id
      t.string :conversion_type
      t.timestamps
    end
  end
end
