class ForecastsController < ApplicationController
  def index
  end

  def create
    # Reject nil or blank addresses, redirect to error
    # address is an ivar so it can be used in the form to pre-fill the input
    @address = params[:address]
    if @address.blank?
      redirect_to root_path, alert: "Please enter an address"
    else
      api_key = ENV['VISUAL_CROSSING_API_KEY']

      client = VisualCrossingWeatherClient.new(api_key: api_key)

      weather = client.get_weather(address: @address)
      @days    = weather&.dig("days")
      @current_conditions = weather&.dig("currentConditions")

      render :index
    end
  end
end