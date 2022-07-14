class ApplicationController < ActionController::API
  include ActionController::Cookies
  include ActionController::HttpAuthentication::Basic::ControllerMethods
  include Pundit

  before_action :add_request_log
  # for ActiveRecord resource render
  def render_resource(resource)
    if resource.errors.empty?
      success!(resource)
    else
      error!(resource.errors.full_messages.join("\n"), resource.errors)
    end
  end
  
  def render_api_result(result, is_alert = false)
    status = 200

    status = 400 if result[:meta][:code] != 200
    # code 201 if for client alert
    result[:meta][:code] = 201 if result[:meta][:code] == 200 && is_alert

    render status: status, json: result
  end

   # code 201 if for client alert
  def success!(data = nil, message = 'success', code = 200)
    res = {
      meta: {
        code: code,
        message: message
      },
      data: data
    }
    render json: res
  end

  # success with alert message
  def success_alert!(message, data = nil)
    success!(data, message, 201)
  end

  # code 202 if for client alert warning
  def warning!(message = 'success but warning', data = nil)
    success!(data, message, 202)
  end

  # code 301 if for client redirect
  def redirect!(url, message = '')
    render json: {
      meta: {
        code: 301,
        message: message,
      },
      data: url,
    }
  end

  def error!(message = 'Internal Error', data = nil)
    uuid = UUIDTools::UUID.timestamp_create().to_s

    render json: {
      meta: {
        code: 500,
        message: message,
        uuid: uuid,
      },
      data: data
    }, status: :bad_request

    EsLog.error(request.url, {email: current_user && current_user["email"], params: params, message: message, uuid: uuid})
  end

  def unauthorized!
    render json: {
      meta: {
        code: 401,
        message: "unauthorized",
      },
    }, status: :unauthorized
  end

  rescue_from Exception do |exception|
    raise if Rails.env.development?
    uuid = UUIDTools::UUID.timestamp_create().to_s
    
    render :json => {'meta': {
      'code': 500,
      'message': exception.message || 'Invaid Request',
      'uuid': uuid
    }}, status: 500

    EsLog.error(request.url, {email: current_user && current_user.email, params: params, message: exception.to_s + exception.backtrace.first(4).inspect, uuid: @uuid})
  end

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protected
  
  def check_user_login
    if current_user
      if current_user.pass_changed.blank? || current_user.pass_changed == current_user.created_at || current_user.pass_changed.utc <= (Time.now - 90.days).utc
        token = current_user.send(:set_reset_password_token)
        tip = "User first login"
        tip = "No password change for 90 days" if current_user.pass_changed.present? && current_user.pass_changed.utc <= (Time.now - 90.days).utc

        redirect!("/users/password/edit?reset_password_token=#{token}", "#{tip}, please reset your password.")
      end
    else
      unauthorized!
    end
  end

  # provide for admin
  def authenticate_api!
    # authorization = request.headers["Authorization"]
    # if authorization.present?
    #   if authorization.include?("Basic")
    #     authenticate_with_http_basic do  |u, token|
    #       unauthorized! if token != ENV['AUTH_API_KEY']
    #     end
    #   else
    #     unauthorized! if authorization != ENV["AUTH_API_KEY"]
    #   end
    # else
    #   unauthorized!
    # end
    true
  end

  def authenticate_user!
    token = cookies["#{request.host}_access_token"]
    if token.present?
      begin
        @current_user = User.find(AuthToken.decode(token)[0]["uid"])
      rescue
        unauthorized!
      end
    else
      unauthorized!
    end
  end

  def user_not_authorized(exception)
    error!("Access denied!")
  end

  def check_utility
    if params[:utility].present?
      return authorize Permission, "#{params[:utility]}?"
    end

    return true
  end

  def check_permit_controller
    authorize Permission, "show_#{params[:controller]}?"
  end

  def check_action_write
    authorize Permission, "show_#{params[:controller]}_write?"
  end

  def add_request_log
    params.permit!
    EsLog.info(request.url, { email: current_user && current_user["email"], message: "" })
  end
end