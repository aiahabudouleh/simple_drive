class CreateS3BlobStorages < ActiveRecord::Migration[7.0]
  def change
    create_table :s3_blob_storages do |t|
      t.references :blob, null: false, foreign_key: true
      t.string :s3_key
      t.string :s3_url

      t.timestamps
    end
  end
end
