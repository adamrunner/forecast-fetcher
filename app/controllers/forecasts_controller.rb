class ForecastsController < ApplicationController
  def index
  end

  def create
    # Get the address from the form
    # TODO - Sanitize the address
    # TODO - Validate the address
    # Reject no addresses, redirect to error
    address = params[:address]
    if address.blank?
      redirect_to root_path, alert: "Please enter an address"
    else
      # Get the start_date and end_date from the form
      start_date = params[:start_date]
      end_date   = params[:end_date]

      # Get the API key from the environment
      api_key = ENV['VISUAL_CROSSING_API_KEY']

      # Create a new instance of the VisualCrossingWeatherClient
      # should this be moved into an initializer?
      client = VisualCrossingWeatherClient.new(api_key: api_key)

      # Get the weather for the address, start_date, and end_date
      @weather = client.get_weather(address: address, start_date: start_date, end_date: end_date)
      @days    = @weather&.dig("days")
      @current_conditions = @weather&.dig("currentConditions")
      # Render the index view
      render :index
    end
  end
end