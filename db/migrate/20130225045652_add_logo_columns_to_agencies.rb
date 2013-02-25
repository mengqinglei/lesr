class AddLogoColumnsToAgencies < ActiveRecord::Migration
  def self.up
    add_attachment :agencies, :logo
  end

  def self.down
    remove_attachment :agencies, :logo
  end
end
