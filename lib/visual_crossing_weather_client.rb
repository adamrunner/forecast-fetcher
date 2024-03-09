require 'uri'
require 'net/http'
require 'openssl'
require 'json'

VISUAL_CROSSING_API_URL = 'https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline'

class VisualCrossingWeatherClient
  def initialize(api_key:)
    raise ArgumentError, 'api_key cannot be blank' if api_key.nil?
    @uri       = URI(VISUAL_CROSSING_API_URL)
    @api_key   = api_key
    @uri.query = URI.encode_www_form({ key: @api_key, include: 'current,days'})
  end

  def get_weather(address:)
    set_path(address)
    JSON.parse(send_request)
  end

  private
  def set_path(address)
    address = URI.encode_uri_component(address)
    # VisualCrossing API requires the address to be passed as part of the path
    @uri.path = "#{@uri.path}/#{address}"
  end

  def send_request
    http = Net::HTTP.new(@uri.host, @uri.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(@uri)

    response = http.request(request)
    body = response.read_body
  end
end