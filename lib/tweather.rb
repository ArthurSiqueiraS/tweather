class Tweather
  class << self
    def send_tweet(city_id)
      tweet_text = build_text(city_id)

      return unless tweet_text.present?

      twitter = Twitter::REST::Client.new do |config|
        config.consumer_key    = Rails.application.credentials.twitter[:key]
        config.consumer_secret = Rails.application.credentials.twitter[:secret_key]
        config.access_token = Rails.application.credentials.twitter[:access_token]
        config.access_token_secret = Rails.application.credentials.twitter[:access_token_secret]
      end

      tweet = twitter.update(tweet_text)

      { tweet_url: tweet.url.to_s, tweet_text: tweet.text }
    end

    private

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
end