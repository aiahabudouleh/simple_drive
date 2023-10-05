# app/services/api/v1/local_storage_service.rb
module Api
  module V1
    class LocalStorageService
      def create(blob, file_data, file_name)
        storage_path = ENV['LOCAL_STORAGE_PATH']

        FileUtils.mkdir_p(storage_path) unless Dir.exist?(storage_path)

        source_path = File.join(storage_path, file_name)
        Rails.logger.debug("LocalStorageService: Source Path: #{source_path}")
        Rails.logger.debug("LocalStorageService: File Data Length: #{file_data.length}")

        File.open(source_path, 'wb') { |f| f.write(file_data) }

        # Update the blob record with the source path
        blob.update(source_path: source_path)

        { blob: blob, error: nil, source_path: source_path }
      rescue StandardError => e
        handle_error("Error saving file to local storage", e)
      end

      def retrieve_blob_data(blob_id)
        Rails.logger.debug("LocalStorageService: Retrieving file content from Local Storage")

        blob = Blob.find_by(id: blob_id)
        return nil unless blob

        file_data = File.binread(blob.source_path)
        Rails.logger.debug("LocalStorageService: File Data Successfully Read from Local Storage - Length: #{file_data.length}")

        file_data
      rescue StandardError => e
        handle_error("Error retrieving file data", e)
      end


      def retrieve_blob_data(blob_id)
        Rails.logger.debug("LocalStorageService: Retrieving file content from Local Storage")

        blob = Blob.find_by(id: blob_id)
        return nil unless blob

        file_data = File.binread(blob.source_path)
        Rails.logger.debug("LocalStorageService: File Data Successfully Read from Local Storage - Length: #{file_data.length}")

        file_data
      rescue StandardError => e
        handle_error("Error retrieving file data", e)
      end

      private

      def handle_error(message, error)
        Rails.logger.error("LocalStorageService: #{message}: #{error.message}")
        raise "Failed to #{message.downcase}. #{error.message}"
      end
    end
  end
end
