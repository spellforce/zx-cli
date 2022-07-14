class Management::PermissionsController < ApplicationController
  before_action :authenticate_api!
  before_action :track_before_action

  # api
  def get_permissions
    success!(Permission.get_js_tree_data)
  end

  # api
  def update
    result = Permission.update_permission(params)
    if result[:success]
      success!(result[:data])
    else
      error!(result[:message])
    end
  end

  # api
  def reparent
    result = Permission.reparent_permission(params)
    if result[:success]
      success!(result[:data])
    else
      error!(result[:message])
    end
  end

  # api
  def create
    result = Permission.create_permission(params)
    if result[:success]
      success!(result[:data])
    else
      error!(result[:message])
    end
  end

  # api
  def delete
    result = Permission.delete_permission(params, ahoy)
    if result[:success]
      success!(result[:data])
    else
      error!(result[:message])
    end
  end

  def track_before_action
    case params[:action]
      when 'reparent'
        ahoy.track "Reparent UO Permission", ActiveSupport::JSON.encode(params)
      when 'create'
        ahoy.track "Create UO Permission", ActiveSupport::JSON.encode(params)
      when 'update'
        ahoy.track "Update UO Permission", ActiveSupport::JSON.encode(params)
      when 'delete'
        ahoy.track "Destroy UO Permission", ActiveSupport::JSON.encode(params)
    end
  end
end
