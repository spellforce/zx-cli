class OptionController < ApplicationController
  before_action :authenticate_user!
  before_action :check_permit_controller
  before_action :track_before_action
  before_action :check_action_write, only: [:create, :update, :delete, :rule_create, :rule_update, :rule_delete]

  def list
    result = HttpClient.post("#{ENV['CONFIGURATION_API']}/api-configuration/v1/option/page", {
      body:  params[:option],
      email: current_user && current_user.email
    })
    render_api_result(result)
  end

  def create
    result = HttpClient.post("#{ENV['CONFIGURATION_API']}/api-configuration/v1/option/create", {
      body:  params[:option],
      email: current_user && current_user.email
    })
    render_api_result(result, true)
  end

  def update
    result = HttpClient.post("#{ENV['CONFIGURATION_API']}/api-configuration/v1/option/update", {
      body:  params[:option],
      email: current_user && current_user.email
    })
    render_api_result(result, true)
  end

  def delete
    result = HttpClient.get("#{ENV['CONFIGURATION_API']}/api-configuration/v1/option/delete/#{params[:id]}", {
      email: current_user && current_user.email
    })
    render_api_result(result, true)
  end

  def show
    result = HttpClient.get("#{ENV['CONFIGURATION_API']}/api-configuration/v1/option/show/#{params[:id]}", {
      email: current_user && current_user.email
    })
    render_api_result(result)
  end

  def get_group_names
    result = HttpClient.get("#{ENV['CONFIGURATION_API']}/api-configuration/v1/option/group_names", {
      email: current_user && current_user.email
    })
    render_api_result(result)
  end

  def rule_list
    result = HttpClient.get("#{ENV['CONFIGURATION_API']}/api-configuration/v1/dynamic_rule/find/#{params[:id]}", {
      email: current_user && current_user.email
    })
    render_api_result(result)
  end

  def rule_create
    result = HttpClient.post("#{ENV['CONFIGURATION_API']}/api-configuration/v1/dynamic_rule/create", {
      body:  params[:option],
      email: current_user && current_user.email
    })
    render_api_result(result, true)
  end

  def rule_update
    result = HttpClient.post("#{ENV['CONFIGURATION_API']}/api-configuration/v1/dynamic_rule/update", {
      body:  params[:option],
      email: current_user && current_user.email
    })
    render_api_result(result, true)
  end

  def rule_delete
    result = HttpClient.get("#{ENV['CONFIGURATION_API']}/api-configuration/v1/dynamic_rule/delete/#{params[:id]}", {
      email: current_user && current_user.email
    })
    render_api_result(result, true)
  end

  def track_before_action
    case params[:action]
      when 'create'
        ahoy.track "Create Option", ActiveSupport::JSON.encode(params)
      when 'update'
        ahoy.track "Update Option", ActiveSupport::JSON.encode(params)
      when 'delete'
        ahoy.track "Delete Option", ActiveSupport::JSON.encode(params)
      when 'rule_create'
        ahoy.track "Create Option Rule", ActiveSupport::JSON.encode(params)
      when 'rule_update'
        ahoy.track "Update Option Rule", ActiveSupport::JSON.encode(params)
      when 'rule_delete'
        ahoy.track "Delete Option Rule", ActiveSupport::JSON.encode(params)
      when 'show'
        ahoy.track "Show Option", ActiveSupport::JSON.encode(params)
    end
  end
end
