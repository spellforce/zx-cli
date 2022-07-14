class CustomFailure < Devise::FailureApp
  # https://github.com/plataformatec/devise/blob/master/lib/devise/failure_app.rb
  # You need to override respond to eliminate recall
  def respond
    if http_auth?
      http_auth
    else
      self.status = :unauthorized
      self.response_body = { :meta => {:code => :unauthorized, :message => i18n_message } }.to_json
      self.content_type = "json"
    end
  end
end