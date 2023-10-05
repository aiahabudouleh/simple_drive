# db/migrate/20231005130000_drop_local_blob_storage_and_create_s3_blob_storages.rb
class DropLocalBlobStorageAndCreateS3BlobStorages < ActiveRecord::Migration[6.0]
    def up
      # Drop the LocalBlobStorage table
      drop_table :local_blob_storages if table_exists?(:local_blob_storages)
  
      # Drop the S3BlobStorage table
      drop_table :s3_blob_storages if table_exists?(:s3_blob_storages)
    end
  
    def change
      # Add the new column
      add_column :blobs, :source_path, :string
  
      # Remove the reference to blob_storages
      remove_reference :s3_blob_storages, :blob, foreign_key: true
    end
  end
  