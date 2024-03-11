class ForecastsController < ApplicationController
  rescue_from VisualCrossingWeatherClient::Error, with: :render_error_message
  def index
  end

  def create
    # Reject nil or blank addresses, redirect to error
    # address is an ivar so it can be used in the form to pre-fill the input
    @address = params[:address]
    if @address.blank?
      redirect_to root_path, alert: "Please enter an address"
    else
      client  = VisualCrossingWeatherClient.new(api_key: api_key)

      @weather            = client.get_weather(address: @address)
      @current_conditions = @weather&.dig("currentConditions")
      @days               = @weather&.dig("days")
      @cached             = @weather&.dig("cached")

      render :index
    end
  end

  def render_error_message(exception)
    @alert = exception.message
    render :index
  end

  private
  def api_key
    ENV['VISUAL_CROSSING_API_KEY']
  end
end