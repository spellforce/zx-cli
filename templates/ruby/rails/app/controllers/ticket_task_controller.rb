class TicketTaskController < ApplicationController
  before_action :authenticate_user!
  before_action :check_permit_controller
  before_action :track_before_action
  before_action :check_action_write, only: [:create, :import, :task_kill, :task_create, :attach_config, :delete_config]

  def list
    result = HttpClient.post("#{ENV['TICKET_AND_TASK_API']}/api-jira/v1/listJiraTicket", {
      body:  params[controller_name],
      email: current_user && current_user.email
    })
    render_api_result(result)
  end

  def operation_list
    result = HttpClient.post("#{ENV['CONFIGURATION_API']}/api-configuration/v1/operation/page", {
      body:  params[controller_name],
      email: current_user && current_user.email
    })
    render_api_result(result)
  end

  def utility_config_list
    result = HttpClient.post("#{ENV['CONFIGURATION_API']}/api-configuration/v1/config/utility/page", {
      body:  params[controller_name],
      email: current_user && current_user.email
    })
    render_api_result(result)
  end

  def create
    params[controller_name][:reporter] = current_user && current_user.email
    result = HttpClient.post("#{ENV['TICKET_AND_TASK_API']}/api-jira/v1/createJiraTicket", {
      body:  params[controller_name],
      email: current_user && current_user.email
    })
    render_api_result(result, true)
  end

  def delete
    result = HttpClient.get("#{ENV['TICKET_AND_TASK_API']}/api-jira/v1/deleteTicket/#{params[:id]}", {
      email: current_user && current_user.email
    })
    render_api_result(result, true)
  end

  def import
    result = HttpClient.post("#{ENV['TICKET_AND_TASK_API']}/api-jira/v1/importJiraTicket", {
      body:  params[controller_name],
      email: current_user && current_user.email
    })
    render_api_result(result, true)
  end

  def task_list

    result = HttpClient.post("#{ENV['TICKET_AND_TASK_API']}/api-jira/v1/getTaskWithAccessAndPage", {
      body:  params[controller_name],
      email: current_user && current_user.email,
      headers: { email: current_user.email }
    })
    render_api_result(result)
  end

  def task_log
    result = HttpClient.post("#{ENV['TASK_INFO_API']}/api-executor/v1/getTaskRealTimeLog", {
      body:  params[controller_name],
      email: current_user && current_user.email
    })
    render_api_result(result)
  end

  def task_summary
    result = HttpClient.get("#{ENV['TASK_INFO_API']}/api-executor/v1/getTaskSummary", { 
      params: { taskKey: params[:taskKey] },
      email: current_user && current_user.email
    })
    render_api_result(result)
  end

  def task_kill
    result = HttpClient.post("#{ENV['TICKET_AND_TASK_API']}/api-jira/v1/killTask", { 
      body:  params[controller_name],
      email: current_user && current_user.email
    })
    render_api_result(result, true)
  end

  # def task_options
  #   params[controller_name][:submitter] = current_user && current_user.email
  #   result = HttpClient.post("#{ENV['TICKET_AND_TASK_API']}/api-jira/v1/getRerunTaskOptions", { 
  #     body:  params[controller_name],
  #     email: current_user && current_user.email,
  #   })
  #   render_api_result(result)
  # end

  def task_create
    params[controller_name][:submitter] = current_user && current_user.email
    result = HttpClient.post("#{ENV['TICKET_AND_TASK_API']}/api-jira/v1/createTask", {
      body:  params[controller_name],
      email: current_user && current_user.email,
    })
    render_api_result(result, true)
  end

  def attach_config
    result = HttpClient.post("#{ENV['TICKET_AND_TASK_API']}/api-jira/v1/createJiraConfiguration", {
      body:  params[controller_name],
      email: current_user && current_user.email,
    })
    render_api_result(result, true)
  end

  def config_list
    result = HttpClient.get("#{ENV['TICKET_AND_TASK_API']}/api-jira/v1/getConfigOnTicket/#{params[:id]}", {
      email: current_user && current_user.email,
    })
    render_api_result(result)
  end

  def delete_config
    result = HttpClient.get("#{ENV['TICKET_AND_TASK_API']}/api-jira/v1/deleteConfigOnTicket/#{params[:id]}", {
      email: current_user && current_user.email,
    })
    render_api_result(result, true)
  end

  def getJiraOptions
    params[controller_name][:submitter] = current_user && current_user.email
    result = HttpClient.post("#{ENV['TICKET_AND_TASK_API']}/api-jira/v1/getJiraOptions", {
      body:  params[controller_name],
      email: current_user && current_user.email,
    })
    render_api_result(result)
  end

  def track_before_action
    case params[:action]
      when 'create'
        ahoy.track "Create Ticket", ActiveSupport::JSON.encode(params)
      when 'import'
        ahoy.track "Import Ticket", ActiveSupport::JSON.encode(params)
      when 'task_create'
        ahoy.track "Ticket Create Task", ActiveSupport::JSON.encode(params)
      when 'attach_config'
        ahoy.track "Ticket Attach Config", ActiveSupport::JSON.encode(params)
      when 'delete_config'
        ahoy.track "Ticket Delete Config", ActiveSupport::JSON.encode(params)
    end
  end
end
