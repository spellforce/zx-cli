class Management::OperationGroupController  < ApplicationController
  before_action :authenticate_user!
  before_action { authorize Permission, :show_management? }
  before_action :track_before_action

  def user_list
    result = User.pageTable(params)

    success!(result)
  end

  def user_group_permission_list
    result = HttpClient.post("#{ENV['CONFIGURATION_API']}/api-configuration/v1/data/permission/show", {
      body:  params[:operation_group],
      email: current_user && current_user.email
    })
    render_api_result(result)
  end

  def list
    result = HttpClient.post("#{ENV['CONFIGURATION_API']}/api-configuration/v1/data/permission/search", {
      body:  params[:operation_group],
      email: current_user && current_user.email
    })
    render_api_result(result)
  end

  def user_group_create
    result = HttpClient.post("#{ENV['CONFIGURATION_API']}/api-configuration/v1/data/permission/add", {
      body:  params[:operation_group],
      email: current_user && current_user.email
    })
    render_api_result(result)
  end

  def user_group_destroy
    result = HttpClient.post("#{ENV['CONFIGURATION_API']}/api-configuration/v1/data/permission/remove", {
      body:  params[:operation_group],
      email: current_user && current_user.email
    })
    render_api_result(result)
  end

  def tree
    result = HttpClient.get("#{ENV['CONFIGURATION_API']}/api-configuration/v1/dictionary/operation_group/tree", {
      email: current_user && current_user.email
    })
    render_api_result(result)
  end

  def tree_search
    result = HttpClient.post("#{ENV['CONFIGURATION_API']}/api-configuration/v1/dictionary/operation_group/node/filter", {
      body:  params[:operation_group],
      email: current_user && current_user.email
    })
    render_api_result(result)
  end

  def create
    result = HttpClient.post("#{ENV['CONFIGURATION_API']}/api-configuration/v1/dictionary/operation_group/node/create", {
      body:  params[:operation_group],
      email: current_user && current_user.email
    })
    render_api_result(result, true)
  end

  def update
    result = HttpClient.post("#{ENV['CONFIGURATION_API']}/api-configuration/v1/dictionary/operation_group/node/edit", {
      body:  params[:operation_group],
      email: current_user && current_user.email
    })
    render_api_result(result, true)
  end

  def delete
    result = HttpClient.get("#{ENV['CONFIGURATION_API']}/api-configuration/v1/dictionary/operation_group/node/delete/#{params[:id]}", {
      email: current_user && current_user.email
    })
    render_api_result(result, true)
  end

  def track_before_action
    case params[:action]
      when 'user_group_create'
        ahoy.track "Create operation group to user", ActiveSupport::JSON.encode(params)
      when 'user_group_destroy'
        ahoy.track "Destroy user operation group", ActiveSupport::JSON.encode(params)
      when 'update'
        ahoy.track "Update operation group", ActiveSupport::JSON.encode(params)
      when 'create'
        ahoy.track "Create operation group", ActiveSupport::JSON.encode(params)
      when 'delete'
        ahoy.track "Destroy operation group", ActiveSupport::JSON.encode(params)
    end
  end
end
