# app/services/api/v1/blob_creator_service.rb
module Api
  module V1
    class BlobCreatorService
      def initialize(name:, uuid:, file:, storage_type:)
        @name = name
        @uuid = uuid
        @file = file
        @storage_type = storage_type
      end

      def create
        blob = nil

        ActiveRecord::Base.transaction do
          blob = Blob.create!(
            name: @name,
            uuid: @uuid,
            size: @file.size,
            storage_type: @storage_type
          )

          BlobStorage.create!(
            blob_id: blob.id,
            file_data: @file.read
          )
        end

        blob
      rescue ActiveRecord::RecordNotUnique => e
        # Handle duplicate entry
        Rails.logger.error("Error creating Blob: #{e.message}")
        nil
      rescue StandardError => e
        # Handle other errors
        Rails.logger.error("Error creating Blob: #{e.message}")
        nil
      end
    end
  end
end
