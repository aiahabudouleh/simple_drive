# app/services/api/v1/s3_storage_service.rb
module Api
  module V1
    class S3StorageService
      class << self
        def create(blob, file)
          filename_without_extension = File.basename(file.original_filename, '.*')
          s3_key = "#{filename_without_extension}"

          Rails.logger.info("S3StorageService: Creating blob record and uploading file to S3 with key: #{s3_key}")
          
          # Upload file to S3
          file_url = S3Client.upload_file(file.tempfile, s3_key)
          
          Rails.logger.info("S3StorageService: File uploaded successfully to S3 with URL: #{file_url}")

          # Save record to S3BlobStorage
          S3BlobStorage.create!(
            blob_id: blob.id,
            s3_key: s3_key,
            s3_url: file_url
          )
        rescue StandardError => e
          Rails.logger.error("S3StorageService: Error saving file to S3 storage: #{e.message}")
          raise "Failed to save file to S3 storage. #{e.message}"
        end

        def retrieve_blob_data(blob_id)
          s3_storage = S3BlobStorage.find_by(blob_id: blob_id)

          return unless s3_storage

          s3_key = s3_storage.s3_key
          filename = File.basename(s3_key)

          Rails.logger.info("S3StorageService: Retrieving file content from S3 with key: #{s3_key}")

          # Reuse the same Tempfile throughout the method
          temp_file = Tempfile.new(filename)
          local_path = temp_file.path

          file_content = S3Client.download_file(s3_key, local_path)

          if file_content
            Rails.logger.info("S3StorageService: File content successfully retrieved from S3")
            {
              filename: filename,
              content: file_content
            }
          else
            Rails.logger.error("S3StorageService: Error retrieving file content from S3")
            nil
          end

          # Close and unlink the temporary file after use
          temp_file.close
          temp_file.unlink
        end
      end
    end
  end
end
