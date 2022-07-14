class ConfigurationController < ApplicationController
  before_action :authenticate_user!
  before_action :check_permit_controller
  before_action :check_utility
  before_action :track_before_action
  before_action :check_action_write, only: [:create, :copy, :delete, :prove, :option_add, :option_delete]
  
  def list
    result = HttpClient.post("#{ENV['CONFIGURATION_API']}/api-configuration/v1/config/page", {
      body:  params[:configuration],
      email: current_user && current_user.email
    })
    render_api_result(result)
  end

  def create
    result = HttpClient.post("#{ENV['CONFIGURATION_API']}/api-configuration/v1/config/create", {
      body:  params[:configuration],
      email: current_user && current_user.email
    })
    render_api_result(result, true)
  end

  def copy
    result = HttpClient.post("#{ENV['CONFIGURATION_API']}/api-configuration/v1/config/copy", {
      body:  params[:configuration],
      email: current_user && current_user.email
    })
    render_api_result(result, true)
  end

  def update
    result = HttpClient.post("#{ENV['CONFIGURATION_API']}/api-configuration/v1/config/edit", {
      body:  params[:configuration],
      email: current_user && current_user.email
    })
    render_api_result(result, true)
  end

  def delete
    result = HttpClient.get("#{ENV['CONFIGURATION_API']}/api-configuration/v1/config/delete/#{params[:id]}", {
      email: current_user && current_user.email
    })
    render_api_result(result, true)
  end

  def prove
    result = HttpClient.get("#{ENV['CONFIGURATION_API']}/api-configuration/v1/config/prove/#{params[:id]}", {
      email: current_user && current_user.email
    })
    render_api_result(result, true)
  end

  def operations
    result = HttpClient.post("#{ENV['CONFIGURATION_API']}/api-configuration/v1/operation/page", {
      body:  params[:configuration],
      email: current_user && current_user.email,
      headers: { email: current_user.email }
    })
    render_api_result(result)
  end

  def option_list
    result = HttpClient.get("#{ENV['CONFIGURATION_API']}/api-configuration/v1/config/details/#{params[:id]}", {
      email: current_user && current_user.email
    })
    render_api_result(result)
  end

  def option_add
    result = HttpClient.post("#{ENV['CONFIGURATION_API']}/api-configuration/v1/config/add/option", {
      body:  params[:configuration],
      email: current_user && current_user.email
    })
    render_api_result(result, true)
  end

  def option_update
    result = HttpClient.post("#{ENV['CONFIGURATION_API']}/api-configuration/v1/config/detail/update", {
      body:  params[:configuration],
      email: current_user && current_user.email
    })
    render_api_result(result, true)
  end

  def option_add_json
    result = HttpClient.post("#{ENV['CONFIGURATION_API']}/api-configuration/v1/config/add/json/option", {
      body:  params[:configuration],
      email: current_user && current_user.email
    })
    render_api_result(result, true)
  end

  def option_delete
    result = HttpClient.get("#{ENV['CONFIGURATION_API']}/api-configuration/v1/config/detail/remove/#{params[:id]}", {
      email: current_user && current_user.email
    })
    render_api_result(result, true)
  end

  def option_page_list
    result = HttpClient.post("#{ENV['CONFIGURATION_API']}/api-configuration/v1/option/page", {
      body:  params[:configuration],
      email: current_user && current_user.email
    })
    render_api_result(result)
  end

  def dy_option_list
    result = HttpClient.post("#{ENV['CONFIGURATION_API']}/api-configuration/v1/config/page/other/options", {
      body:  params[:configuration],
      email: current_user && current_user.email
    })
    render_api_result(result)
  end

  def track_before_action
    case params[:action]
      when 'create'
        ahoy.track "Create Configuration", ActiveSupport::JSON.encode(params)
      when 'copy'
        ahoy.track "Copy Configuration", ActiveSupport::JSON.encode(params)
      when 'delete'
        ahoy.track "Delete Configuration", ActiveSupport::JSON.encode(params)
      when 'prove'
        ahoy.track "Prove Configuration", ActiveSupport::JSON.encode(params)
      when 'option_add'
        ahoy.track "Configuration Add Option", ActiveSupport::JSON.encode(params)
      when 'option_add_json'
        ahoy.track "Configuration Add Option By Json", ActiveSupport::JSON.encode(params)
      when 'option_update'
        ahoy.track "Configuration Update Option", ActiveSupport::JSON.encode(params)
      when 'option_delete'
        ahoy.track "Configuration Delete Option", ActiveSupport::JSON.encode(params)
    end
  end
end
