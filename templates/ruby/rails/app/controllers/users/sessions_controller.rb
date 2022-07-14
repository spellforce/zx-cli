# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  respond_to :json
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   self.resource = warden.authenticate!(auth_options)
  #   set_flash_message!(:notice, :signed_in)
  #   sign_in(resource_name, resource)
  #   yield resource if block_given?
  #   respond_with resource, location: after_sign_in_path_for(resource)
  # end
  def create
    schema = {
      type: "object",
      required: [],
      properties: {
        user: { type: "object", properties: {
          email: { type: "string" },
          password: { type: "string" }
        }},
      }
    }

    error!("Parameters are invalid.") and return unless JSON::Validator.validate(schema, params.to_h)
    
    user = User.where({ email: params[:user][:email] }).first
    if user.present? && user.failed_attempts == 2
      UserMailer.user_password(email: params[:user][:email]).deliver_now
    end

    self.resource = warden.authenticate!(auth_options)
    if resource.active == 1
      cookies["#{request.host}_access_token"] = {
        value: AuthToken.encode({ uid: resource.id }),
        path: '/',
        expires: 1.week,
        domain: request.domain,
        httponly: true,
      }
      user = {
        email: resource.email,
        username: resource.username,
        permissions: resource.permissions
      }
      UserLoginHistory.create_from_request(request, params)
      success!(user)
    else
      error!('This user has been locked! Please contact admin.')
    end
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
  private

  # def respond_to_on_destroy
  #   # We actually need to hardcode this as Rails default responder doesn't
  #   # support returning empty response on GET request
  #   respond_to do |format|
  #     format.all { head :no_content }
  #     format.any(*navigational_formats) { redirect_to after_sign_out_path_for(resource_name) }
  #   end
  # end

  def respond_to_on_destroy
    cookies.delete(:alert)
    cookies.delete(:access_token)
    success!
  end
end
