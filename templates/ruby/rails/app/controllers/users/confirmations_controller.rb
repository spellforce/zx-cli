# frozen_string_literal: true

class Users::ConfirmationsController < Devise::ConfirmationsController
  # GET /resource/confirmation/new
  # def new
  #   super
  # end

  # POST /resource/confirmation
  # def create
  #   super
  # end

  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    schema = {
      type: "object",
      required: [],
      properties: {
        confirmation_token: { type: "string" },
      }
    }

    error!("Parameters are invalid.") and return unless JSON::Validator.validate(schema, params.to_h)
    
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    cookies[:alert] = {
      value: 'Confirm email successed. You can login now.',
      expires: 30.seconds,
    }
    if resource.errors.empty?
      respond_with_navigational(resource){ redirect_to "//#{ENV['SELF_HOST']}/users/login" }
    else
      render_resource(resource)
    end
  end

  # protected

  # The path used after resending confirmation instructions.
  # def after_resending_confirmation_instructions_path_for(resource_name)
  #   super(resource_name)
  # end

  # The path used after confirmation.
  # def after_confirmation_path_for(resource_name, resource)
  #   super(resource_name, resource)
  # end
end
