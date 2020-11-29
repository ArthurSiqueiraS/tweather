class TweatherController < ApplicationController
  def post
    # Bad request if city id is not integer
    begin
      city_id = Integer(params[:cityId])
    rescue ArgumentError, TypeError
      return render_bad_request
    end

    response = Tweather.send_tweet(city_id)
    return render_not_found(city_id) unless response.present?

    render json: response, status: :created
  end

  private

  def render_bad_request
    render json: "Bad request, ID must be an integer", status: :bad_request
  end

  def render_not_found(id)
    return render json: "City not found for ID #{id}", status: :not_found
  end
end
