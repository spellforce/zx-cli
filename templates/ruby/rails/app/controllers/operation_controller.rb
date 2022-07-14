require 'yaml'

class OperationController < ApplicationController
  before_action :authenticate_user!
  before_action :check_permit_controller, except: [:permit_group, :list]
  before_action :track_before_action
  before_action :check_action_write, only: [:create, :update, :copy, :delete, :option_add, :option_delete]

  def list
    result = HttpClient.post("#{ENV['CONFIGURATION_API']}/api-configuration/v1/operation/page", {
      body:  params[controller_name],
      email: current_user && current_user.email,
      headers: { email: current_user.email }
    })
    render_api_result(result)
  end

  def create
    result = HttpClient.post("#{ENV['CONFIGURATION_API']}/api-configuration/v1/operation/create", {
      body:  params[controller_name],
      email: current_user && current_user.email
    })
    render_api_result(result, true)
  end

  def group_tree
    result = HttpClient.get("#{ENV['CONFIGURATION_API']}/api-configuration/v1/operation/group/tree", {
      email: current_user && current_user.email,
      headers: { email: current_user.email }
    })
    render_api_result(result)
  end

  def validate_engine_conf
    yaml = params[:value]
    begin
      parsed_yaml = YAML.load(yaml)   
      # p parsed_yaml.class
      success!(parsed_yaml.instance_of?(Hash) || parsed_yaml.instance_of?(Array))
    rescue => exception
      success!(false)
    end
  end

  def update
    result = HttpClient.post("#{ENV['CONFIGURATION_API']}/api-configuration/v1/operation/update", {
      body:  params[controller_name],
      email: current_user && current_user.email
    })
    render_api_result(result, true)
  end

  def copy
    result = HttpClient.post("#{ENV['CONFIGURATION_API']}/api-configuration/v1/operation/copy", {
      body:  params[controller_name],
      email: current_user && current_user.email
    })
    render_api_result(result, true)
  end

  def delete
    result = HttpClient.get("#{ENV['CONFIGURATION_API']}/api-configuration/v1/operation/delete/#{params[:id]}", {
      email: current_user && current_user.email
    })
    render_api_result(result, true)
  end

  def option_list
    result = HttpClient.get("#{ENV['CONFIGURATION_API']}/api-configuration/v1/operation/options/#{params[:id]}", {
      email: current_user && current_user.email
    })
    render_api_result(result)
  end

  def option_add
    result = HttpClient.post("#{ENV['CONFIGURATION_API']}/api-configuration/v1/operation/add/option", {
      body:  params[controller_name],
      email: current_user && current_user.email
    })
    render_api_result(result, true)
  end

  def option_update
    result = HttpClient.post("#{ENV['CONFIGURATION_API']}/api-configuration/v1/operation/edit/option", {
      body:  params[controller_name],
      email: current_user && current_user.email
    })
    render_api_result(result, true)
  end

  def option_delete
    result = HttpClient.get("#{ENV['CONFIGURATION_API']}/api-configuration/v1/operation/remove/option/#{params[:id]}", {
      email: current_user && current_user.email
    })
    render_api_result(result, true)
  end

  def output_list
    result = HttpClient.get("#{ENV['CONFIGURATION_API']}/api-configuration/v1/operation/outputs/#{params[:id]}", {
      email: current_user && current_user.email
    })
    render_api_result(result)
  end

  def output_add
    result = HttpClient.post("#{ENV['CONFIGURATION_API']}/api-configuration/v1/operation/add/output", {
      body:  params[controller_name],
      email: current_user && current_user.email
    })
    render_api_result(result, true)
  end

  def output_update
    result = HttpClient.post("#{ENV['CONFIGURATION_API']}/api-configuration/v1/operation/edit/output", {
      body:  params[controller_name],
      email: current_user && current_user.email
    })
    render_api_result(result, true)
  end

  def output_delete
    result = HttpClient.get("#{ENV['CONFIGURATION_API']}/api-configuration/v1/operation/remove/output/#{params[:id]}", {
      email: current_user && current_user.email
    })
    render_api_result(result, true)
  end

  def nodes_list
    result = HttpClient.get("#{ENV['CONFIGURATION_API']}/api-configuration/v1/operation/output_input/relations/#{params[:id]}", {
      email: current_user && current_user.email
    })
    render_api_result(result)
  end

  def nodes_add
    result = HttpClient.post("#{ENV['CONFIGURATION_API']}/api-configuration/v1/operation/add/output_input/relation", {
      body:  params[controller_name],
      email: current_user && current_user.email
    })
    render_api_result(result, true)
  end

  def nodes_delete
    result = HttpClient.get("#{ENV['CONFIGURATION_API']}/api-configuration/v1/operation/remove/output_input/relation/#{params[:id]}", {
      email: current_user && current_user.email
    })
    render_api_result(result, true)
  end

  def nodes_options
    result = HttpClient.get("#{ENV['CONFIGURATION_API']}/api-configuration/v1/operation/compound/linkage/oi/pipelines/#{params[:id]}", {
      email: current_user && current_user.email
    })
    render_api_result(result)
  end

  def option_page_list
    result = HttpClient.post("#{ENV['CONFIGURATION_API']}/api-configuration/v1/option/page", {
      body:  params[controller_name],
      email: current_user && current_user.email
    })
    render_api_result(result)
  end

  def executions
    result = HttpClient.post("#{ENV['CONFIGURATION_API']}/api-configuration/v1/operation/executions", {
      body:  params[controller_name],
      email: current_user && current_user.email
    })
    render_api_result(result)
  end

  def dy_option_list
    result = HttpClient.post("#{ENV['CONFIGURATION_API']}/api-configuration/v1/option/dynamic/page", { 
      body: params[controller_name],
      email: current_user && current_user.email
    })
    render_api_result(result)
  end

  def permit_group
    params[controller_name][:search].push({
      key: 'user_email',
      value: current_user && current_user.email
    })
    result = HttpClient.post("#{ENV['CONFIGURATION_API']}/api-configuration/v1/data/permission/show", {
      body:  params[controller_name],
      email: current_user && current_user.email
    })
    render_api_result(result)
  end

  def track_before_action
    case params[:action]
      when 'create'
        ahoy.track "Create Operation", ActiveSupport::JSON.encode(params)
      when 'update'
        ahoy.track "Update Operation", ActiveSupport::JSON.encode(params)
      when 'copy'
        ahoy.track "Copy Operation", ActiveSupport::JSON.encode(params)
      when 'delete'
        ahoy.track "Delete Operation", ActiveSupport::JSON.encode(params)
      when 'option_add'
        ahoy.track "Operation Add Option", ActiveSupport::JSON.encode(params)
      when 'option_delete'
        ahoy.track "Operation Delete Option", ActiveSupport::JSON.encode(params)
    end
  end
end
