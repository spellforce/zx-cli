class ReleaseManagementController < ApplicationController
  before_action :authenticate_user!
  before_action :check_permit_controller

  # https://gridxwiki.atlassian.net/wiki/spaces/frontend/pages/1117389246/Release+Management+Design
  def get_envs
    result = HttpClient.post("#{ENV['RELEASE_MANAGEMENT_API']}/api-release-management/v1/getUtilityEnv", {
      body:  params[controller_name],
      email: current_user && current_user.email
    })
    render_api_result(result)
  end

  def get_latest_release_info 
    result = HttpClient.post("#{ENV['RELEASE_MANAGEMENT_API']}/api-release-management/v1/getLatestReleaseInfo", {
      body:  params[controller_name],
      email: current_user && current_user.email
    })
    render_api_result(result)
  end
end
