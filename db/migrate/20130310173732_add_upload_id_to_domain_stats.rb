class AddUploadIdToDomainStats < ActiveRecord::Migration
  def change
    add_column :domain_stats, :upload_id, :integer
  end
end
