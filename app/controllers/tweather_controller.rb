class TweatherController < ApplicationController
  def post
    # Bad request if city id is not integer
    begin
      city_id = Integer(params[:cityId])
    rescue ArgumentError, TypeError
      return render_bad_request
    end

    tweet_text = build_text(city_id)

    return render_not_found(city_id) unless tweet_text.present?

    response = {
      tweet_url: 'https://twitter.com/tweatherapi/status/1332854276633354240',
      text: tweet_text
    }

    render json: response, status: :created
  end

  private

  def render_bad_request
    render json: "Bad request, ID must be an integer", status: :bad_request
  end

  def render_not_found(id)
    return render json: "City not found for ID #{id}", status: :not_found
  end

  def build_text(city_id)
    open_weather = OpenWeather.new

    # Create string for current day weather
    current_weather_data = open_weather.city_weather(city_id)
    current_weather_string = build_current_weather_string(current_weather_data)

    return unless current_weather_string.present?

    # Create string for forecasts
    forecast_data = open_weather.city_forecast(city_id)
    forecast_string = build_forecast_string(forecast_data[:forecast])

    "#{current_weather_string}. Média para os próximos dias: #{forecast_string}."
  end

  def build_current_weather_string(current_weather)
    return unless current_weather.present?

    temp = current_weather[:temp].round
    conditions = current_weather[:weather_conditions].join(', ')
    city = current_weather[:city]
    today = mmdd(current_weather[:date])

    "#{temp}°C e #{conditions} em #{city} em #{today}"
  end

  def build_forecast_string(forecast)
    string = ''
    conjunction = nil
    # Concatenate temperatures and days in a string with proper conjunctions
    forecast.each_with_index do |(day, temp), index|
      conjunction = ', ' if index > 0
      conjunction = ' e ' if index == forecast.length - 1
      string += "#{conjunction}#{temp.round}°C em #{mmdd(day)}"
    end

    string
  end

  def mmdd(date)
    _, month, day = date.split('-')
    "#{day}/#{month}"
  end
end
