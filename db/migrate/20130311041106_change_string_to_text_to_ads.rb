class ChangeStringToTextToAds < ActiveRecord::Migration
  def change
      change_column :ads, :headline, :text
      change_column :ads, :line1, :text
      change_column :ads, :line2, :text
      change_column :ads, :display_url, :text
      change_column :ads, :destination_url, :text
  end
end
