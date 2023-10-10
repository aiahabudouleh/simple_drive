module Api
  module V1
    class S3StorageService
      def create(blob, file_data, file_name)
        filename_without_extension = File.basename(file_name, '.*')
        s3_key = "#{filename_without_extension}"

        # Upload file to S3
        file_url = S3HttpClient.upload_file(file_data, s3_key)

        Rails.logger.info("S3StorageService: File uploaded successfully to S3 with URL: #{file_url}")

        update_blob_path(blob, s3_key)

        { message: 'File uploaded successfully', file_url: file_url }
      rescue StandardError => e
        handle_error("Error saving file to S3 storage", e)
      end

      def retrieve_blob_data(blob_id)
        blob = Blob.find(blob_id)
        s3_key = blob.source_path
        filename = File.basename(s3_key)

        Rails.logger.info("S3StorageService: Retrieving file content from S3 with key: #{s3_key}")

        # Provide a local_path, for example, a temporary file
        temp_file = Tempfile.new(filename)
        local_path = temp_file.path

        downloaded_file = S3HttpClient.download_file(s3_key, local_path)

        if downloaded_file
          # Return the file content
          downloaded_file
        else
          raise StandardError, 'Error downloading file'
        end
      rescue StandardError => e
        handle_error("Error retrieving file content from S3", e)
      end

      private

      def update_blob_path(blob, s3_key)
        blob.update(source_path: s3_key)
      end

      def generate_s3_url(s3_key)
        "https://#{ENV['AWS_BUCKET']}.s3.amazonaws.com/#{s3_key}"
      end

      def handle_error(message, error)
        Rails.logger.error("S3StorageService: #{message}: #{error.message}")
        raise "Failed to #{message.downcase}. #{error.message}"
      end
    end
  end
end
