require 'net/http'
require 'uri'
require 'openssl'
require_relative '../util/canonical_request_util'

class S3HttpClient
  AWS_ACCESS_KEY_ID = ENV['AWS_ACCESS_KEY_ID']
  AWS_SECRET_ACCESS_KEY = ENV['AWS_SECRET_ACCESS_KEY']
  AWS_BUCKET = ENV['AWS_BUCKET']
  AWS_REGION = ENV['AWS_REGION']

  class << self
    def download_file(s3_key, file_path)
      uri = build_s3_uri(s3_key)
      Rails.logger.info("URI: #{uri}")

      request = Net::HTTP::Get.new(uri, {
        'Content-Type' => 'application/json'
      })

      sign_s3_request(request)
      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end

      handle_response(response)
    end

    def upload_file(local_file_path, s3_key)
      uri = build_s3_uri(s3_key)
      Rails.logger.info("Upload URI: #{uri}")

      request = Net::HTTP::Put.new(uri, {
        'Content-Type' => 'application/octet-stream'
      })

      request.body = File.read(local_file_path)

      sign_s3_request(request)

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end

      handle_response(response)
    end


    private

    def build_s3_uri(s3_key)
      URI.parse("https://#{AWS_BUCKET}.s3.#{AWS_REGION}.amazonaws.com/#{s3_key}")
    end

    def sign_s3_request(request)
      content_sha256 = OpenSSL::Digest.new('sha256').hexdigest(request.body || '')
      amz_date = Time.now.utc.strftime('%Y%m%dT%H%M%SZ')

      request['x-amz-content-sha256'] = content_sha256
      request['x-amz-date'] = amz_date
      request['host'] = request.uri.host

      canonical_request = build_canonical_request(request)

      hashed_canonical_request = Digest::SHA256.hexdigest(canonical_request)
      string_to_sign = build_string_to_sign(amz_date, hashed_canonical_request)
      date = Time.now.utc.strftime('%Y%m%dT%H%M%SZ')
      signing_key = build_signing_key(date)
      signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), signing_key, string_to_sign)

      signed_headers = canonical_request_util.signed_headers(request.each_header.to_h)
      request['Authorization'] = build_authorization_header(signature, amz_date, signed_headers)
      request['host'] = "#{AWS_BUCKET}.s3.#{AWS_REGION}.amazonaws.com"
    end

    def build_canonical_request(request)
      [
        request.method,
        canonical_request_util.path(request.uri),
        '', # Query
        canonical_request_util.canonical_headers(request.each_header.to_h) + "\n",
        canonical_request_util.signed_headers(request.each_header.to_h),
        OpenSSL::Digest.new('sha256').hexdigest(request.body || ''),
      ].join("\n")
    end

    def build_string_to_sign(amz_date, hashed_canonical_request)
      algorithm = 'AWS4-HMAC-SHA256'
      credential_scope = "#{amz_date[0..7]}/#{AWS_REGION}/s3/aws4_request"

      "#{algorithm}\n#{amz_date}\n#{credential_scope}\n#{hashed_canonical_request}"
    end

    def build_authorization_header(signature, amz_date, signed_headers)
      credential = "#{AWS_ACCESS_KEY_ID}/#{amz_date[0..7]}/#{AWS_REGION}/s3/aws4_request"

      "AWS4-HMAC-SHA256 Credential=#{credential}, SignedHeaders=#{signed_headers}, Signature=#{signature}"
    end

    def build_signing_key(date)
      k_date = OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), "AWS4#{AWS_SECRET_ACCESS_KEY}", date)
      k_region = OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), k_date, AWS_REGION)
      k_service = OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), k_region, 's3')
      k_signing = OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), k_service, 'aws4_request')
      k_signing
    end

    def handle_response(response)
      if response.code.to_i == 200
        response.body
      else
        raise "Failed request: #{response.code} - #{response.body}"
      end
    end

    def canonical_request_util
      @canonical_request_util ||= CanonicalRequestUtil.new
    end
  end
end
