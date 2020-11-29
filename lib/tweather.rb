class Tweather
  attr_accessor :twitter_client

  def initialize
    self.twitter_client = Twitter::REST::Client.new do |config|
      config.consumer_key        = Rails.application.credentials.twitter[:key]
      config.consumer_secret     = Rails.application.credentials.twitter[:secret_key]
      config.access_token        = Rails.application.credentials.twitter[:access_token]
      config.access_token_secret = Rails.application.credentials.twitter[:access_token_secret]
    end
  end

  def create_tweet(city_id)
    weather_data = get_weather_data(city_id)
    return unless weather_data.present?

    tweet_text = build_text(weather_data)
    lat = weather_data[:current_weather][:city][:lat]
    lon = weather_data[:current_weather][:city][:lon]

    tweet_response = send_tweet(tweet_text, lat, lon)

    response = { tweet_url: tweet_response[:url], tweet_text: tweet_text }
    if tweet_response[:duplicate]
      response[:message] = "O texto gerado era uma duplicata de um tweet recente e não foi publicado."
    end

    response
  end

  private

  def get_weather_data(city_id)
    open_weather = OpenWeather.new

    current_weather = open_weather.city_weather(city_id)
    return unless current_weather.present?

    forecast_data = open_weather.city_forecast(city_id)

    { current_weather: current_weather, forecast: forecast_data[:forecast] }
  end

  def send_tweet(text, lat, lon)
    tweet_options = { lat: lat, long: lon, display_coordinates: 'true' }
    duplicate = nil

    begin
      tweet = twitter_client.update!(text, tweet_options)
    rescue Twitter::Error::DuplicateStatus => e
      # In case of duplicate searches for last tweet with same text by @tweatherapi
      tweets_query = twitter_client.search("#{text} (from:tweatherapi)", { result_type: 'recent' })
      duplicate_tweets = tweets_query.select { |t| t.user.screen_name == 'tweatherapi' }
      tweet = duplicate_tweets.first

      duplicate = true
    end

    { url: tweet.url.to_s, duplicate: duplicate }
  end

  def build_text(weather_data)
    # Create string for current day weather
    current_weather_string = build_current_weather_string(weather_data[:current_weather])

    # Create string for forecasts
    forecast_string = build_forecast_string(weather_data[:forecast])

    "#{current_weather_string}. Média para os próximos dias: #{forecast_string}."
  end

  def build_current_weather_string(current_weather)
    return unless current_weather.present?

    temp = current_weather[:temp].round
    conditions = current_weather[:weather_conditions].join(', ')
    city = current_weather[:city][:name]
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