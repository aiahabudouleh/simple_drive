# app/services/api/v1/local_storage_service.rb
module Api
  module V1
    class LocalStorageService
      def self.create(blob, file_data)
        storage_path = ENV['LOCAL_STORAGE_PATH']
        FileUtils.mkdir_p(storage_path) unless Dir.exist?(storage_path)

        file_path = File.join(storage_path, "#{blob.uuid}_file.txt")
        File.binwrite(file_path, file_data)

        LocalBlobStorage.create!(
          blob_id: blob.id,
          file_path: file_path
        )
      rescue StandardError => e
        raise "Failed to save file to local storage. #{e.message}"
      end

      def self.retrieve(blob)
        storage_path = ENV['LOCAL_STORAGE_PATH']
        file_path = File.join(storage_path, "#{blob.uuid}_file.txt")

        File.read(file_path, mode: 'rb')
      rescue StandardError => e
        raise "Failed to retrieve file from local storage. #{e.message}"
      end
    end
  end
end
