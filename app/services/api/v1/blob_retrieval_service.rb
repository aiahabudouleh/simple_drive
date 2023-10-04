# app/services/api/v1/blob_retrieval_service.rb
require_relative 'db_storage_service'
require_relative 'local_storage_service'
require_relative 's3_storage_service'

# app/services/api/v1/blob_retrieval_service.rb
module Api
  module V1
    class BlobRetrievalService
      class UnsupportedStorageType < StandardError; end

      def self.retrieve_blob_data(blob_id)
        blob = Blob.find_by(id: blob_id)
        return nil unless blob

        storage_type = blob.storage_type
        storage_service = storage_service_factory(storage_type)

        if storage_service
          storage_service.retrieve_blob_data(blob_id)
        else
          raise UnsupportedStorageType, "Unsupported storage type: #{storage_type}"
        end
      end

      private

      def self.storage_service_factory(storage_type)
        case storage_type
        when 'db_storage'
          Api::V1::DBStorageService
        when 'local_storage'
          Api::V1::LocalStorageService
        when 's3_storage'
          Api::V1::S3StorageService
        else
          nil
        end
      end
    end
  end
end
