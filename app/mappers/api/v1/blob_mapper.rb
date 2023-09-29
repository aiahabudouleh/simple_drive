# app/mappers/api/v1/blob_mapper.rb
module Api
    module V1
      class BlobMapper
        def self.map(blob, blob_storage)
          {
            id: blob.uuid,
            size: blob.size,
            created_at: blob.created_at.utc,
            file_data: utf8_encoded_file_data(blob_storage)
          }
        end
  
        private
  
        def self.utf8_encoded_file_data(blob_storage)
          return nil unless blob_storage
  
          file_data = blob_storage.file_data
          utf8_encoded_data = file_data.force_encoding('UTF-8').encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
  
          utf8_encoded_data
        end
      end
    end
  end
  