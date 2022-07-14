#encoding: utf-8
class Management::UsersController < ApplicationController
  before_action :authenticate_api!
  before_action :track_before_action

  def get_records
    schema = {
      type: "object",
      required: [],
      properties: {
        pagination: { type: "object", properties: {
          current: { type: "integer" },
          pageSize: { type: "integer", maximum: 500 },
        }},
        sortField: { type: "string" },
        sortDirection: { type: "string", enum: ["ASC", "DESC", nil] }
      }
    }

    error!("Parameters are invalid.") and return unless JSON::Validator.validate(schema, params.to_h) 

    result = User.pageTable(params)

    success!(result)
  end

  # api
  def create
    user = User.new(params.permit(:email, :password, :username, :password_confirmation).merge({active: true, approved: true}))
    user.roles = Role.where(id: params.permit({role_ids: []})[:role_ids])
    if user.save
      success!(nil, "Create successfully.")
    else
      error!(user.errors.full_messages.join("\n"))
    end
  end

  # api
  def update
    schema = {
      type: "object",
      required: [],
      properties: {
        id: { type: "integer" },
        email: { type: "string" },
        username: { type: "string" }
      }
    }

    error!("Parameters are invalid.") and return unless JSON::Validator.validate(schema, params.to_h) 

    user = User.find(params[:id])
    user.email   = params[:email]
    user.username = params[:username]

    if params[:password].present?
      user.password = params[:password]
      user.password_confirmation = params[:password_confirmation]
    end

    user.roles = Role.where(id: params.permit({role_ids: []})[:role_ids])
    
    if user.save
      success!(nil, "Update successfully.")
    else
      error!(user.errors.full_messages.join("\n"))
    end
  end

  def destroy
    schema = {
      type: "object",
      required: [],
      properties: {
        id: { type: "integer" },
      }
    }

    error!("Parameters are invalid.") and return unless JSON::Validator.validate(schema, params.to_h)

    user = User.find(params[:id])
    if user.active == 1
      error!('Please deactive this user first!')
      return
    end
    if user && user.destroy
      success!(nil, "Delete successfully.")
    else
      error!(user.errors.full_messages.join('<br/>'))
    end
  end

  # api
  def lock
    schema = {
      type: "object",
      required: [],
      properties: {
        id: { type: "integer" },
      }
    }

    error!("Parameters are invalid.") and return unless JSON::Validator.validate(schema, params.to_h)

    user = User.find(params[:id])
    user.active = false
    if user.save
      success!(nil, "Lock successfully.")
    else
      error!(user.errors.full_messages.join("\n"))
    end
  end

  # api
  def unlock
    schema = {
      type: "object",
      required: [],
      properties: {
        id: { type: "integer" },
      }
    }

    error!("Parameters are invalid.") and return unless JSON::Validator.validate(schema, params.to_h)

    user = User.find(params[:id])
    user.active = true
    if user.save
      success!(nil, "Unlock successfully.")
    else
      error!(user.errors.full_messages.join("\n"))
    end
  end

  def approve
    schema = {
      type: "object",
      required: [],
      properties: {
        id: { type: "integer" },
      }
    }

    error!("Parameters are invalid.") and return unless JSON::Validator.validate(schema, params.to_h)
    
    user = User.find(params[:id])
    user.approved = true
    if user.save
      success!(nil, "Approve successfully.")
    else
      error!(user.errors.full_messages.join("\n"))
    end
  end

  protected

  def track_before_action
    case params[:action]
      when 'create'
        ahoy.track "Create User", ActiveSupport::JSON.encode(params)
      when 'update'
        ahoy.track "Update User", ActiveSupport::JSON.encode(params)
      when 'lock'
        ahoy.track "Lock User", ActiveSupport::JSON.encode(params)
      when 'unlock'
        ahoy.track "Unlock User", ActiveSupport::JSON.encode(params)
      when 'prove'
        ahoy.track "Prove User", ActiveSupport::JSON.encode(params)
    end
  end
end
