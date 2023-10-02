# app/services/api/v1/local_storage_service.rb
module Api
  module V1
    class LocalStorageService
      def self.create(blob, file)
        file_name= file.original_filename
        file_data = file.read
        storage_path = ENV['LOCAL_STORAGE_PATH']
        FileUtils.mkdir_p(storage_path) unless Dir.exist?(storage_path)

        file_path = File.join(storage_path, "#{file_name}")
        Rails.logger.debug("**** File Path: #{file_path}") # Add this line
        Rails.logger.debug("File Data Length: #{file_data.length}") # Add this line
        File.open(file_path, 'wb') { |f| f.write(file_data) }
        
        LocalBlobStorage.create!(
          blob_id: blob.id,
          file_path: file_path
        )
      rescue StandardError => e
        raise "Failed to save file to local storage. #{e.message}"
      end

      def self.retrieve_blob_data(blob_id)
        local_blob_storage = LocalBlobStorage.find_by(blob_id: blob_id)

        if local_blob_storage
          Rails.logger.debug("Local Blob Storage Found - File Path: #{local_blob_storage.file_path}")

          begin
            file_data = File.binread(local_blob_storage.file_path)
            Rails.logger.debug("File Data Successfully Read from Local Storage")
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
