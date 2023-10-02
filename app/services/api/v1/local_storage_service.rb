# app/services/api/v1/local_storage_service.rb
module Api
  module V1
    class LocalStorageService
      class << self
        def create(blob, file_data, file_name)
          storage_path = ENV['LOCAL_STORAGE_PATH']
          FileUtils.mkdir_p(storage_path) unless Dir.exist?(storage_path)

          file_path = File.join(storage_path, file_name)
          Rails.logger.debug("LocalStorageService: File Path: #{file_path}")
          Rails.logger.debug("LocalStorageService: File Data Length: #{file_data.length}")

          File.open(file_path, 'wb') { |f| f.write(file_data) }

          LocalBlobStorage.create!(
            blob_id: blob.id,
            file_path: file_path
          )
        rescue StandardError => e
          Rails.logger.error("LocalStorageService: Error saving file to local storage: #{e.message}")
          raise "Failed to save file to local storage. #{e.message}"
        end

        def retrieve_blob_data(blob_id)
          local_blob_storage = LocalBlobStorage.find_by(blob_id: blob_id)

          if local_blob_storage
            Rails.logger.debug("LocalStorageService: Local Blob Storage Found - File Path: #{local_blob_storage.file_path}")

            begin
              file_data = File.binread(local_blob_storage.file_path)
              Rails.logger.debug("LocalStorageService: File Data Successfully Read from Local Storage - Length: #{file_data.length}")
              return file_data
            rescue StandardError => e
              Rails.logger.error("LocalStorageService: Error reading file from local storage: #{e.message}")
              raise "Failed to read file from local storage. #{e.message}"
            end
          else
            Rails.logger.debug("LocalStorageService: Local Blob Storage Not Found")
            return nil
          end
        end
      end
    end
  end
end
