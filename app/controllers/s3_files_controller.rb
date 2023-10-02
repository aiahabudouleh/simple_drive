# app/controllers/s3_files_controller.rb
class S3FilesController < ApplicationController
    def upload
      file = params[:file]
      filename_without_extension = File.basename(file.original_filename, '.*')
      s3_key = "#{filename_without_extension}"
      puts "Upload S3_key : #{s3_key}"
      file_url = S3Client.upload_file(file.tempfile, s3_key)
  
      if file_url
        render json: { message: 'File uploaded successfully', file_url: file_url }
      else
        render json: { error: 'Error uploading file' }, status: :internal_server_error
      end
    end
  
    def download
        filename = params[:filename]
        s3_key = "#{filename}"
        puts "Download S3_key : #{s3_key}"

        # Provide a local_path, for example, a temporary file
        temp_file = Tempfile.new(filename)
        local_path = temp_file.path
    
        file_content = S3Client.download_file(s3_key, local_path)
    
        if file_content
          send_data file_content, filename: filename, disposition: 'inline'
    
          # Ensure the temporary file is closed and unlinked after sending data
          temp_file.close
          temp_file.unlink
        else
          render json: { error: 'Error downloading file' }, status: :not_found
        end
      end
  end
  