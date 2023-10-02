# app/services/api/v1/blob_creator_service.rb
require_relative 'db_storage_service'
require_relative 'local_storage_service'
require_relative 's3_storage_service'

module Api
  module V1
    class BlobCreatorService
      class UnsupportedStorageType < StandardError; end

      def initialize(name:, uuid:, file:, storage_type:)
        @name = name
        @uuid = uuid
        @file = file
        @storage_type = storage_type
        @file_data = @file.read
      end

      def create
        ActiveRecord::Base.transaction do
          blob = create_blob_record
          storage_service = storage_service_factory(@storage_type)
          storage_service.create(blob, @file_data, @file.original_filename)
          { blob: blob, error: nil, file_data: @file_data }
        rescue ActiveRecord::RecordInvalid => e
          handle_record_invalid_error(e)
        rescue UnsupportedStorageType, StandardError => e
          handle_error(e)
        end
      end

      private

      def create_blob_record
        Blob.create!(
          name: @name,
          uuid: @uuid,
          size: @file.size,
          storage_type: @storage_type
        )
      end

      def storage_service_factory(storage_type)
        case storage_type
        when 'db_storage'
          Api::V1::DBStorageService
        when 'local_storage'
          Api::V1::LocalStorageService
        when 's3_storage'
          Api::V1::S3StorageService  # Fixed to use S3StorageService for 's3_storage'
        else
          raise UnsupportedStorageType, "Unsupported storage type: #{@storage_type}"
        end
      end

      def handle_record_invalid_error(e)
        error_message = e.message
        Rails.logger.error("Error creating blob: #{error_message}")

        { blob: nil, error: "Failed to create blob. #{error_message}" }
      end

      def handle_error(e)
        error_message = e.message
        Rails.logger.error("Error: #{error_message}")

        { blob: nil, error: error_message }
      end
    end
  end
end
