# app/controllers/api/v1/blobs_controller.rb
module Api
  module V1
    class BlobsController < ApplicationController
      before_action :set_blob, only: [:show]
      before_action :authorize_request, except: [:logn, :signup]

      def create
        validator = Api::V1::BlobCreatorValidator.new
        validator.validate_params(params)

        uploaded_file = params[:data]

        if uploaded_file.respond_to?(:size)
          created_blob = create_blob(uploaded_file)

          if created_blob[:success]
            render json: { blob: Api::V1::BlobMapper.map(created_blob[:blob], created_blob[:file_data]) }, status: :created
          else
            render json: { error: created_blob[:error] }, status: :unprocessable_entity
          end
        else
          render json: { error: 'Invalid file format or file missing size method' }, status: :unprocessable_entity
        end
      end

      def show
        if @blob
          render json: { blob: Api::V1::BlobMapper.map(@blob, @blob_data) }, status: :ok
        else
          render json: { error: 'Blob not found' }, status: :not_found
        end
      end

      private

      def create_blob(uploaded_file)
        Rails.logger.info("BlobsController: Creating blob from uploaded file")

        result = Api::V1::BlobCreatorService.new(
          name: uploaded_file.original_filename,
          uuid: params[:id],
          file: uploaded_file,
          storage_type: ENV['STORAGE_TYPE']
        ).create

        if result[:blob]
          blob = result[:blob]
          blob_storage = BlobStorage.find_by(blob_id: blob.id)
          Rails.logger.info("BlobsController: Blob created successfully - Blob ID: #{blob.id}")
          { success: true, blob: blob, file_data: result[:file_data] }
        else
          Rails.logger.error("BlobsController: Error creating blob: #{result[:error]}")
          { success: false, error: result[:error] }
        end
      end

      def set_blob
        @blob = Blob.find_by(uuid: params[:id])
        
        @blob_data = retrieve_blob_data(@blob.id) if @blob
      end

      def retrieve_blob_data(blob_id)
        Rails.logger.debug("BlobsController: Retrieving blob data for blob_id #{blob_id}")
        Api::V1::BlobRetrievalService.retrieve_blob_data(blob_id)
      end
    end
  end
end
