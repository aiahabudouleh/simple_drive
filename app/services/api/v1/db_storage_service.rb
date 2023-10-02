# app/services/api/v1/db_storage_service.rb
module Api
  module V1
    class DBStorageService
      class << self
        def create(blob, file)
          file_data = file.read
          Rails.logger.debug("DBStorageService: Creating BlobStorage record for blob_id #{blob.id}")
          BlobStorage.create!(
            blob_id: blob.id,
            file_data: file_data 
          )
        rescue StandardError => e
          Rails.logger.error("DBStorageService: Error creating BlobStorage record: #{e.message}")
          raise e
        end

        def retrieve_blob_data(blob_id)
          Rails.logger.debug("DBStorageService: Retrieving file_data for blob_id #{blob_id}")
          BlobStorage.find_by(blob_id: blob_id)&.file_data
        rescue StandardError => e
          Rails.logger.error("DBStorageService: Error retrieving file_data: #{e.message}")
          raise e
        end
      end
    end
  end
end
