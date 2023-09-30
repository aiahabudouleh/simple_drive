# app/services/api/v1/blob_retrieval_service.rb
module Api
  module V1
    class BlobRetrievalService

      def self.retrieve_blob_data(blob_id)
        blob = Blob.find_by(id: blob_id)
        return nil unless blob

        storage_type = blob.storage_type
        case storage_type
        when 'db_storage'
          retrieve_from_db_storage(blob_id)
        when 'local_storage'
          retrieve_from_local_storage(blob_id)
        else
          raise UnsupportedStorageType, "Unsupported storage type: #{storage_type}"
        end
      end

      private

      def self.retrieve_from_db_storage(blob_id)
        blob_storage = BlobStorage.find_by(blob_id: blob_id)

        if blob_storage
          #Rails.logger.debug("Blob Storage Content: #{blob_storage.file_data.inspect}")
          blob_storage.file_data
        else
          nil
        end
      end

      def self.retrieve_from_local_storage(blob_id)
        local_blob_storage = LocalBlobStorage.find_by(blob_id: blob_id)
      
        if local_blob_storage
          Rails.logger.debug("Local Blob Storage Found - File Path: #{local_blob_storage.file_path}")
      
          begin
            file_data = File.binread(local_blob_storage.file_path)
            Rails.logger.debug("File Data Successfully Read from Local Storage #{file_data}")
            return file_data
          rescue StandardError => e
            Rails.logger.error("Error reading file from local storage: #{e.message}")
            raise "Failed to read file from local storage. #{e.message}"
          end
        else
          Rails.logger.debug("Local Blob Storage Not Found")
          return nil
        end
      end
      
    end
  end
end
