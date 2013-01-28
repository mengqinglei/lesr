class AddTypeToDomainStats < ActiveRecord::Migration
  def change
    add_column :domain_stats, :type, :string
  end
end
