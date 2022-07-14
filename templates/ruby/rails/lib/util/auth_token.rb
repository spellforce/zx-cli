require 'jwt'

module AuthToken

  # generate token
  def AuthToken.encode(payload)
    # Set expiration to 4 hours.
    payload['exp'] = 1.week.from_now.to_i 
    JWT.encode(payload, Rails.application.secrets.secret_key_base)
  end
  
  # validation token
  def AuthToken.decode(token)
    begin
      JWT.decode(token, Rails.application.secrets.secret_key_base)
    rescue
      false
    end
  end
end