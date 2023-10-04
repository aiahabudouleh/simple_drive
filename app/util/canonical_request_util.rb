require 'set'

class CanonicalRequestUtil
  def initialize
    @unsigned_headers = Set.new(['authorization', 'date', 'user-agent', 'content-length'])
    @signed_headers = 'host;x-amz-content-sha256;x-amz-date;x-amz-date'
  end

  def path(url)
    path = url.path
    path = '/' if path == ''
    path
  end

  def canonical_headers(headers)
    headers = headers.inject([]) do |hdrs, (k, v)|
      if @unsigned_headers.include?(k)
        hdrs
      else
        hdrs << [k, v]
      end
    end
    headers = headers.sort_by(&:first)
    headers.map { |k, v| "#{k}:#{canonical_header_value(v.to_s)}" }.join("\n")
  end

  def canonical_header_value(value)
    value.gsub(/\s+/, ' ').strip
  end

  def downcase_headers(headers)
    (headers || {}).to_hash.transform_keys(&:downcase)
  end

  def signed_headers(headers)
    headers.inject([]) do |signed_headers, (header, _)|
      if @unsigned_headers.include?(header.downcase)
        signed_headers
      else
        signed_headers << header.downcase
      end
    end.sort.join(';')
  end
end
