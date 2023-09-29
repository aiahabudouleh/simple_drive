module Api
    module V1
      class BlobCreatorValidator
        def validate_params(params)
          validate_data(params[:data])
          validate_id(params[:id])
        end
  
        private
  
        def validate_data(data)
          return if data.present?
          raise ValidationError, 'data is required'
        end
  
        def validate_id(id)
          return if id.present?
          raise ValidationError, 'id is required'
        end
      end
  
      class ValidationError < StandardError; end
    end
  end
  