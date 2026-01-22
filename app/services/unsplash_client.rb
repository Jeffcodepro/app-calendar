require "net/http"
require "json"
require "cgi"

class UnsplashClient
  API_URL = "https://api.unsplash.com".freeze

  def self.search_images(destinations)
    destinations.map do |destination|
      {
        name: destination[:name],
        image_url: search_image(destination[:name])
      }
    end
  end

  def self.search_image(query)
    key = ENV["UNSPLASH_ACCESS_KEY"]
    return nil if key.to_s.strip.empty?

    uri = URI("#{API_URL}/search/photos")
    uri.query = URI.encode_www_form(query: query, per_page: 1, orientation: "landscape")
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Client-ID #{key}"

    http = Net::HTTP.new(uri.hostname, uri.port)
    http.use_ssl = true
    http.read_timeout = 5
    http.open_timeout = 5
    http.verify_mode = if ENV["UNSPLASH_INSECURE_SSL"] == "true"
                         OpenSSL::SSL::VERIFY_NONE
                       else
                         OpenSSL::SSL::VERIFY_PEER
                       end

    response = http.request(request)

    return nil unless response.is_a?(Net::HTTPSuccess)

    body = JSON.parse(response.body)
    result = body["results"].to_a.first
    result&.dig("urls", "regular")
  rescue JSON::ParserError, SocketError, Errno::ECONNRESET
    nil
  end
end
