# app/services/api/v1/storage_service_adapter.rb

require_relative 'db_storage_service'
require_relative 'local_storage_service'
module Api
    module V1
      class StorageServiceAdapter
        class UnsupportedStorageType < StandardError; end
  
        def initialize()
          @storage_type = ENV['storage_type']
        end
  
        def create(blob, file, file_data)
          storage_service.create(blob, file, file_data)
        end
  
        def retrieve_blob_data(blob_id)
          storage_service.retrieve_blob_data(blob_id)
        end
  
        private
  
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
      end
    end
  end
  