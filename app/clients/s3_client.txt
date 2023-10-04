require 'aws-sdk-s3'
require 'tempfile'

class S3Client
  AWS_REGION = ENV['AWS_REGION']
  AWS_BUCKET = ENV['AWS_BUCKET']
  AWS_ACCESS_KEY_ID = ENV['AWS_ACCESS_KEY_ID']
  AWS_SECRET_ACCESS_KEY = ENV['AWS_SECRET_ACCESS_KEY']

  Aws.config.update(
    region: AWS_REGION,
    access_key_id: AWS_ACCESS_KEY_ID,
    secret_access_key: AWS_SECRET_ACCESS_KEY
  )

  @s3 = Aws::S3::Resource.new

  def self.upload_file(file_path, s3_key)
    obj = @s3.bucket(AWS_BUCKET).object(s3_key)
    obj.upload_file(file_path)
    
    file_url = obj.public_url.to_s
    puts "File uploaded successfully. : #{obj}"
    puts "File uploaded successfully URL : #{file_url}"

    file_url
  rescue StandardError => e
    puts "Error uploading file: #{e.message}"
    nil
  end

  def self.download_file(s3_key, local_path)
    s3 = Aws::S3::Client.new

    obj = s3.get_object(bucket: AWS_BUCKET, key: s3_key)

    File.open(local_path, 'wb') do |file|
      file.write(obj.body.read)
    end

    local_path
  rescue Aws::S3::Errors::NoSuchKey, Aws::S3::Errors::NotFound => e
    puts "Error: #{e.message}"
    nil
  end
end
