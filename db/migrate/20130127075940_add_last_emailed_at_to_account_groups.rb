class AddLastEmailedAtToAccountGroups < ActiveRecord::Migration
  def change
    add_column :account_groups, :last_emailed_at, :datetime
  end
end
