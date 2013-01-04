class AddVendorToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :vendor, :string
  end
end
