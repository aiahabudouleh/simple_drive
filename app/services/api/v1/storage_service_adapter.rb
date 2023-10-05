require_relative 'db_storage_service'
require_relative 'local_storage_service'
require_relative 's3_storage_service'

module Api
    module V1
      class StorageServiceAdapter
        def initialize(storage_type)
          @storage_type = storage_type
        end
  
        def create(blob, file_data, original_filename)
          storage_service.create(blob, file_data, original_filename)
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