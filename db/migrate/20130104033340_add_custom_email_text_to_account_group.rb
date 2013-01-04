class AddCustomEmailTextToAccountGroup < ActiveRecord::Migration
  def change
    add_column :account_groups, :custom_email_text, :text
  end
end
