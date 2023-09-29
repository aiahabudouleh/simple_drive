# app/controllers/api/v1/blobs_controller.rb
module Api
    module V1
      class BlobsController < ApplicationController
        before_action :set_blob, only: [:show]
  
        def create
          validator = Api::V1::BlobCreatorValidator.new
          validator.validate_params(params)
  
          uploaded_file = params[:data]
  
          if uploaded_file.respond_to?(:size)
            created_blob = create_blob(uploaded_file)
  
            if created_blob && created_blob.persisted?
              render json: { blob: blob_info(created_blob) }, status: :created
            else
              render json: { error: created_blob ? created_blob.errors.full_messages : 'Failed to persist blob' }, status: :unprocessable_entity
            end
          else
            render json: { error: 'Invalid file format or file missing size method' }, status: :unprocessable_entity
          end
        end
  
        def show
          render json: { blob: blob_info(@blob) }, status: :ok
        end
  
        private
  
        def create_blob(uploaded_file)
          Api::V1::BlobCreatorService.new(
            name: uploaded_file.original_filename,
            uuid: params[:id],
            file: uploaded_file,
            storage_type: params[:storage_type]
          ).create
        end
  
        def blob_info(blob)
          {
            id: blob.uuid,
            size: blob.size,
            created_at: blob.created_at.utc
            #data
          }
        end
  
        def set_blob
          @blob = Blob.find_by(uuid: params[:id])
  
          unless @blob
            render json: { error: 'Blob not found' }, status: :not_found
          end
        end
      end
    end
  end
  