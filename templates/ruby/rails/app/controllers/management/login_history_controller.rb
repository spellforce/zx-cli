class Management::LoginHistoryController < ApplicationController
  before_action :authenticate_api!

  def get_records
    result = UserLoginHistory.pageTable(params)
    success!(result)
  end
end
