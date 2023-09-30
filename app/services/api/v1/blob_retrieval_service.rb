# app/services/api/v1/blob_retrieval_service.rb
module Api
  module V1
    class BlobRetrievalService

      def self.retrieve_blob_data(blob_id)
        blob = Blob.find_by(id: blob_id)
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
          Rails.logger.debug("Blob Storage Content: #{blob_storage.file_data.inspect}")
          blob_storage.file_data
        else
          nil
        end
      end

      def self.retrieve_from_local_storage(blob_id)
        local_blob_storage = LocalBlobStorage.find_by(blob_id: blob_id)
        local_blob_storage&.file_path ? File.read(local_blob_storage.file_path, mode: 'rb') : nil
      end
    end
  end
end
