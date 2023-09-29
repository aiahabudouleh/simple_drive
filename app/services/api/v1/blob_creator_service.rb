module Api
  module V1
    class BlobCreatorService
      def initialize(name:, uuid:, file:, storage_type:)
        @name = name
        @uuid = uuid
        @file = file
        @storage_type = storage_type
      end

      def create
        Blob.create!(
          name: @name,
          uuid: @uuid,
          size: calculate_file_size, 
          storage_type: @storage_type
        )
      rescue ActiveRecord::RecordNotUnique => e
        # Handle duplicate entry
      end

      private

      def calculate_file_size
        @file.size if @file.respond_to?(:size)
      end
    end
  end
end
