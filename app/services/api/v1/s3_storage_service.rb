# app/services/api/v1/s3_storage_service.rb
module Api
  module V1
    class S3StorageService
      class << self
        def create(blob, file_data, file_name)
          filename_without_extension = File.basename(file_name, '.*')
          s3_key = "#{filename_without_extension}"

          # Upload file to S3
          file_url = S3HttpClient.upload_file(file_data, s3_key)

          Rails.logger.info("S3StorageService: File uploaded successfully to S3 with URL: #{file_url}")

          save_to_s3_blob_storage(blob, s3_key, file_url)

          { message: 'File uploaded successfully', file_url: file_url }
        rescue StandardError => e
          Rails.logger.error("S3StorageService: Error saving file to S3 storage: #{e.message}")
          raise "Failed to save file to S3 storage. #{e.message}"
        end

        def retrieve_blob_data(blob_id)
          s3_storage = S3HttpClient.find_by(blob_id: blob_id)

          return unless s3_storage

          s3_key = s3_storage.s3_key
          filename = File.basename(s3_key)

          Rails.logger.info("S3StorageService: Retrieving file content from S3 with key: #{s3_key}")

          # Provide a local_path, for example, a temporary file
          temp_file = Tempfile.new(filename)
          local_path = temp_file.path
          downloaded_file = S3Client.download_file(s3_key, local_path)

          if downloaded_file
            # Return the file content
            temp_file.read
          else
            raise StandardError, 'Error downloading file'
          end
        end

        private

        def save_to_s3_blob_storage(blob, s3_key, file_url)
          # Save record to S3BlobStorage
          S3BlobStorage.create!(
            blob_id: blob.id,
            s3_key: s3_key,
            s3_url: file_url
          )
        end
      end
    end
  end
end
