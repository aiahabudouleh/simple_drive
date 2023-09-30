# app/services/api/v1/blob_creator_service.rb
module Api
  module V1
    class BlobCreatorService
      def initialize(name:, uuid:, file:, storage_type:)
        @name = name
        @uuid = uuid
        @file = file
        @storage_type = storage_type
        @file_data = @file.read
      end

      def create
        begin
          blob = nil

          ActiveRecord::Base.transaction do
            blob = Blob.create!(
              name: @name,
              uuid: @uuid,
              size: @file.size,
              storage_type: @storage_type
            )

            case @storage_type
            when 'db_storage'
              Api::V1::DBStorageService.create(blob, @file_data)
            when 'local_storage'
              Api::V1::LocalStorageService.create(blob, @file_data, @file.original_filename)
            end
          end

          { blob: blob, error: nil, file_data: @file_data }
        rescue ActiveRecord::RecordInvalid => e
          # Catching ActiveRecord validation errors
          error_message = e.message
          Rails.logger.error("Error creating blob: #{error_message}")

          { blob: nil, error: "Failed to create blob. #{error_message}" }
        rescue StandardError => e
          # Catching other unexpected errors
          Rails.logger.error("Unexpected error creating blob: #{e.message}")

          { blob: nil, error: "An unexpected error occurred while creating blob. #{e.message}" }
        end
      end

    end
  end
end
