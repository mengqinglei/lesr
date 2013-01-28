class AddProcessedAtToUploads < ActiveRecord::Migration
  def change
    add_column :uploads, :processed_at, :datetime
  end
end
