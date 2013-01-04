class AddSeparatorToAccountGroup < ActiveRecord::Migration
  def change
    add_column :account_groups, :separator, :string
  end
end
