class HealthController < ActionController::Base
  def check
    render json: {
      status: 200
    }
  end
end
