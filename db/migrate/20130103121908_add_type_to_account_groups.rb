class AddTypeToAccountGroups < ActiveRecord::Migration
  def change
    add_column :account_groups, :type, :string
  end
end
