require_relative 'db_storage_service'
require_relative 'local_storage_service'

module Api
  module V1
    class StorageServiceAdapter
      class UnsupportedStorageType < StandardError; end

      def initialize
        @storage_type = ENV['storage_type']
      end

      def create(file, uuid)
        blob = nil
        file_data = file.read
        Rails.logger.info("File_content: #{file_data}");
        ActiveRecord::Base.transaction do
          begin
            blob = create_blob(file, uuid)
            storage_service.create(blob, file_data, file.original_filename)
          rescue ActiveRecord::RecordInvalid => e
            return handle_record_invalid_error(e)
          rescue UnsupportedStorageType, StandardError => e
            return handle_error(e)
          end
        end

        { blob: blob, error: nil, file_data: file_data }
      end

      def retrieve_blob_data(blob_id)
        storage_service.retrieve_blob_data(blob_id)
      end

      private

      def create_blob(file, uuid)
        Blob.create!(
          name: file.original_filename,
          uuid: uuid,
          size: file.size,
          storage_type: @storage_type
        )
      end

      def storage_service
        case @storage_type
        when 'db_storage'
          Api::V1::DBStorageService.new
        when 'local_storage'
          Api::V1::LocalStorageService.new
        when 's3_storage'
          Api::V1::S3StorageService.new
        else
          raise UnsupportedStorageType, "Unsupported storage type: #{@storage_type}"
        end
      end

      def handle_record_invalid_error(error)
        Rails.logger.error("RecordInvalid error: #{error.message}")
        { blob: nil, error: error.message, file_data: nil }
      end

      def handle_error(error)
        Rails.logger.error("Error: #{error.message}")
        { blob: nil, error: error.message, file_data: nil }
      end
    end
  end
end
