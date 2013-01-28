class CreateUploads < ActiveRecord::Migration
  def change
    create_table :uploads do |t|
      t.binary :data

      t.timestamps
    end
  end
end
