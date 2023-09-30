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

            if (@storage_type == 'db_storage')
              BlobStorage.create!(
                blob_id: blob.id,
                file_data: @file_data
              )
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
