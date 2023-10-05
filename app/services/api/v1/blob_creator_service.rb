# app/services/api/v1/blob_creator_service.rb
require_relative 'storage_service_adapter'

module Api
  module V1
    class BlobCreatorService
      class UnsupportedStorageType < StandardError; end

      def initialize(uploaded_file:, uuid:)
        @name = uploaded_file.original_filename
        @uuid = uuid
        @file = uploaded_file
        @storage_adapter = Api::V1::StorageServiceAdapter.new()
        @storage_type = ENV['storage_type']
        @file_data = @file.read
      end

      def create
        ActiveRecord::Base.transaction do
          blob = create_blob_record
          
          @storage_adapter.create(blob, @file_data, @file.original_filename)
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
