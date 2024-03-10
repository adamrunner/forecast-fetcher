require 'uri'
require 'net/http'
require 'openssl'
require 'json'

VISUAL_CROSSING_API_URL = 'https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline'

class VisualCrossingWeatherClient
  def initialize(api_key:)
    raise ArgumentError, 'api_key cannot be blank' if api_key.nil?
    @api_key   = api_key
  end

  def get_weather(address:)
    # extract the zip code from the address if it is present
    # update the request path with the address to be used in the API call
    set_path(strip_address(address))
    # check if the response is already cached, if not, make the request and cache the response
    cache_flag = Rails.cache.exist?(address)
    data = Rails.cache.fetch(address, expires_in: 30.minutes) do
      send_request
    end
    # return the response and a flag indicating if the response was cached
    { "cached" => cache_flag }.merge(data)
  end

  private
  def set_path(address)
    # VisualCrossing API requires the address to be passed as part of the path
    address    = URI.encode_uri_component(address)
    @uri       = URI("#{VISUAL_CROSSING_API_URL}/#{address}")
    @uri.query = URI.encode_www_form({ key: @api_key, include: 'current,days'})
  end

  def send_request
    response = Net::HTTP.get_response(@uri)
    handle_response(response)
  end

  def handle_response(response)
    if response.class.ancestors.include?(Net::HTTPSuccess)
      JSON.parse(response.body)
    elsif response.class.ancestors.include?(Net::HTTPClientError)
      raise VisualCrossingWeatherClient::Error, 'Invalid request. Please check the address and try again.'
    elsif response.class.ancestors.include?(Net::HTTPServerError)
      raise VisualCrossingWeatherClient::Error, 'The VisualCrossing API is currently unavailable. Please try again later.'
    end
  end

  def strip_address(address)
    # naieve implementation to extract the zip code from the address
    # a real production implementation would use a geocoding service
    # and an address validation service to ensure the address is valid
    if zip_code = address.match(/\d{5}$/)
      zip_code[0]
    else
      address
    end
  end
end

class VisualCrossingWeatherClient::Error < StandardError; end