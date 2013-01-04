class AddEmailSettingsToAccountGroup < ActiveRecord::Migration
  def change
    add_column :account_groups, :email_setting, :text
  end
end
