class CreateBlobStorages < ActiveRecord::Migration[7.0]
  def change
    create_table :blob_storages do |t|
      t.references :blob, null: false, foreign_key: true
      t.binary :file_data

      t.timestamps
    end
  end
end
