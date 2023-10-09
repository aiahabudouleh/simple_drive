# app/services/api/v1/db_storage_service.rb
module Api
  module V1
    class DBStorageService
      def create(blob, file_data, file_name)
        Rails.logger.debug("DBStorageService: Creating BlobStorage record for blob_id #{blob.id}")
        BlobStorage.create!(
          blob_id: blob.id,
          file_data: file_data
        )
      rescue StandardError => e
        handle_error("Error creating BlobStorage record", e)
      end

      def retrieve_blob_data(blob_id)
        Rails.logger.debug("DBStorageService: Retrieving file_data for blob_id #{blob_id}")
      
        blob_storage = BlobStorage.find_by(blob_id: blob_id)
      
        if blob_storage
          file_data = blob_storage.file_data
          Rails.logger.info("DBStorageService: File_data retrieved successfully for blob_id #{blob_id}")
          file_data
        else
          raise StandardError, "BlobStorage not found for blob_id #{blob_id}"
        end
      rescue StandardError => e
        handle_error("Error retrieving file_data", e)
      end
      

      private

      def handle_error(message, error)
        Rails.logger.error("DBStorageService: #{message}: #{error.message}")
        raise error
      end
    end
  end
end
