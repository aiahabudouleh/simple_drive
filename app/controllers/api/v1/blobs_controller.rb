module Api
  module V1
    class BlobsController < ApplicationController
      before_action :set_blob, only: [:show]
      before_action :authorize_request, except: [:login, :signup]

      def create
        begin
          Api::V1::BlobCreatorValidator.new.validate_params(params)
          created_blob = Api::V1::StorageServiceAdapter.new.create(params[:data], params[:id])
          render_blob_response(created_blob)
        rescue Api::V1::ValidationError => e
          render json: { error: e.message }, status: :unprocessable_entity
        rescue StandardError => e
          render json: { error: "An unexpected error occurred: #{e.message}" }, status: :internal_server_error
        end
      end
      
      

      def show
        if @blob
          render_blob_response({ blob: @blob, file_data: @blob_data })
        else
          render json: { error: 'Blob not found' }, status: :not_found
        end
      end

      private

      def render_blob_response(response_data)
        if response_data[:error].nil?
          render json: {
            id: response_data[:blob].id,
            size: response_data[:blob].size,
            created_at: response_data[:blob].created_at.utc,
            storage_type: response_data[:blob].storage_type,
            file_data: response_data[:file_data].force_encoding('UTF-8').encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
          }, status: :ok
        else
          render json: { error: response_data[:error] }, status: :unprocessable_entity
        end
      end

      def set_blob
        @blob = Blob.find_by(uuid: params[:id])
      
        if @blob
          Rails.logger.debug("Blob found with UUID: #{params[:id]}")
          @blob_data = retrieve_blob_data(@blob.id)
        else
          Rails.logger.debug("Blob not found with UUID: #{params[:id]}")
        end
      end
      

      def retrieve_blob_data(blob_id)
        Rails.logger.debug("BlobsController: Retrieving blob data for blob_id #{blob_id}")
        Api::V1::StorageServiceAdapter.new.retrieve_blob_data(blob_id)
      end
    end
  end
end
