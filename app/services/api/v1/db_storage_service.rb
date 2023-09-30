# app/services/api/v1/db_storage_service.rb
module Api
    module V1
      class DBStorageService
        def self.create(blob, file_data)
            BlobStorage.create!(
                blob_id: blob.id,
                file_data: @file_data
              )
        end
  
        def self.retrieve (uuid)
            blob_storage = BlobStorage.find_by(blob_id: @blob.id)
            {blob_storage}
      end
    end
  end
  