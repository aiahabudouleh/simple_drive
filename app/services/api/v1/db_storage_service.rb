# app/services/api/v1/db_storage_service.rb
module Api
  module V1
    class DBStorageService
      def self.create(blob, file_data)
        BlobStorage.create!(
          blob_id: blob.id,
          file_data: file_data 
        )
      end
  
      def self.retrieve_from_db_storage(blob_id)
        BlobStorage.find_by(blob_id: blob_id)&.file_data
      end
    end
  end
end
