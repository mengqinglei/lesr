class ChangeStringToTextToAccounts < ActiveRecord::Migration
  def change
      change_column :accounts, :name, :text
  end
end

