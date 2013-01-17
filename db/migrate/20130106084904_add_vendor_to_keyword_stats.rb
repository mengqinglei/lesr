class AddVendorToKeywordStats < ActiveRecord::Migration
  def change
    add_column :keyword_stats, :vendor, :string
  end
end
