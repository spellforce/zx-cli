# frozen_string_literal: true

class Users::PasswordsController < Devise::PasswordsController
  respond_to :json
  # GET /resource/password/new
  # def new
  #   super
  # end

  # POST /resource/password forget password api use
  def create
    schema = {
      type: "object",
      required: [],
      properties: {
        email: { type: "string" },
      }
    }

    error!("Parameters are invalid.") and return unless JSON::Validator.validate(schema, params.to_h)

    user = User.find_by_email(resource_params[:email])
    unless user.present?
      success_alert!(I18n.t("devise.passwords.send_instructions"))
      return
    end

    self.resource = resource_class.send_reset_password_instructions(resource_params)
    if successfully_sent?(resource)
      # success_alert!('Send successfully!')
      success_alert!(I18n.t("devise.passwords.send_instructions"))
    else
      # error!('Send email error!')
      success_alert!(I18n.t("devise.passwords.send_instructions"))
    end
  
    # respond_with({}, :location => after_sending_reset_password_instructions_path_for(resource_name))
    # super
  end

  # GET /resource/password/edit?reset_password_token=abcdef
  # def edit
  #   super
  # end

  # PUT /resource/password
  def update
    schema = {
      type: "object",
      required: [],
      properties: {
        user: { type: "object", properties: {
          password_confirmation: { type: "string" },
          password: { type: "string" },
          reset_password_token: { type: "string" },
        }},
      }
    }

    error!("Parameters are invalid.") and return unless JSON::Validator.validate(schema, params.to_h)
    
    self.resource = resource_class.reset_password_by_token(resource_params)
    
    if resource.errors.empty?
      resource.unlock_access! if unlockable?(resource)
    else
      resource.errors.messages[:password] << "recommended is: #{User.generate_password}" if resource.errors.messages[:password].present?
    end

    render_resource(resource)
  end

  # protected

  # def after_resetting_password_path_for(resource)
  #   super(resource)
  # end

  # The path used after sending reset password instructions
  # def after_sending_reset_password_instructions_path_for(resource_name)
  #   super(resource_name)
  # end
end
