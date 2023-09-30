class CreateLocalBlobStorages < ActiveRecord::Migration[7.0]
  def change
    create_table :local_blob_storages do |t|
      t.references :blob, null: false, foreign_key: true
      t.string :file_path

      t.timestamps
    end
  end
end
