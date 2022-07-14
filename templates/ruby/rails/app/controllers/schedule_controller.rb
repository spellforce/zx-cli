class ScheduleController < ApplicationController
  before_action :authenticate_user!
  before_action :check_permit_controller
  before_action :track_before_action
  before_action :check_action_write, only: [:create, :update, :disable, :enable]

  # https://gridxwiki.atlassian.net/wiki/spaces/frontend/pages/919143279/Scheduler+Service+Design
  def list
    result = HttpClient.post("#{ENV['SCHEDULE_API']}/api-scheduler/v1/getSchedules", {
      body:  params[controller_name],
      email: current_user && current_user.email,
      headers: { email: current_user.email }
    })
    render_api_result(result)
  end

  def task_list
    result = HttpClient.post("#{ENV['SCHEDULE_API']}/api-scheduler/v1/getScheduleTasks", {
      body:  params[controller_name],
      email: current_user && current_user.email
    })
    render_api_result(result)
  end

  def create
    params[controller_name][:username] = current_user && current_user.email
    result = HttpClient.post("#{ENV['SCHEDULE_API']}/api-scheduler/v1/createSchedule", {
      body:  params[controller_name],
      email: current_user && current_user.email
    })
    render_api_result(result, true)
  end

  def update
    params[controller_name][:username] = current_user && current_user.email
    result = HttpClient.put("#{ENV['SCHEDULE_API']}/api-scheduler/v1/updateSchedule", {
      body:  params[controller_name],
      email: current_user && current_user.email
    })
    render_api_result(result, true)
  end

  def disable
    result = HttpClient.put("#{ENV['SCHEDULE_API']}/api-scheduler/v1/disableSchedule/#{params[:id]}", {
      email: current_user && current_user.email
    })
    render_api_result(result, true)
  end

  def enable
    result = HttpClient.put("#{ENV['SCHEDULE_API']}/api-scheduler/v1/enableSchedule/#{params[:id]}", {
      email: current_user && current_user.email
    })
    render_api_result(result, true)
  end

  def get_timeline
    result = HttpClient.get("#{ENV['SCHEDULE_API']}/api-scheduler/v1/getScheduleTimeLine", {
      params: { tz: params[:tz], utility: params[:utility] },
      email: current_user && current_user.email
    })
    render_api_result(result)
  end
  
  def track_before_action
    case params[:action]
      when 'create'
        ahoy.track "Create Schedule", ActiveSupport::JSON.encode(params)
      when 'update'
        ahoy.track "Update Schedule", ActiveSupport::JSON.encode(params)
      when 'disable'
        ahoy.track "Disable Schedule", ActiveSupport::JSON.encode(params)
      when 'enable'
        ahoy.track "Enable Schedule", ActiveSupport::JSON.encode(params)
    end
  end
end
