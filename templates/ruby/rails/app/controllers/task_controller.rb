class TaskController < ApplicationController
  before_action :authenticate_user!
  before_action :check_permit_controller
  
  # https://gridxwiki.atlassian.net/wiki/spaces/frontend/pages/919143279/Scheduler+Service+Design
  def list
    result = HttpClient.post("#{ENV['TASK_INFO_API']}/api-executor/v1/getTaskByPageWithSearch", {
      body:  params[controller_name],
      email: current_user && current_user.email,
      headers: { email: current_user.email }
    })
    render_api_result(result)
  end

  def get_detail
    result = HttpClient.get("#{ENV['TASK_INFO_API']}/api-executor/v1/sparkResource/#{params[:id]}", {
      email: current_user && current_user.email,
    })
    render_api_result(result)
  end

  def release
    result = HttpClient.post("#{ENV['TASK_INFO_API']}/api-executor/v1/sparkResource/release", {
      body:  params[controller_name],
      email: current_user && current_user.email,
    })
    render_api_result(result, true)
  end

  def getAzkabanFlow
    result = HttpClient.post("#{ENV['TASK_INFO_API']}/api-executor/v1/getAzkabanFlows", {
      body:  params[controller_name],
      email: current_user && current_user.email,
    })
    render_api_result(result)
  end
end
