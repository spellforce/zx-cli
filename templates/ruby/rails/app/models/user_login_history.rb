#encoding: utf-8
class UserLoginHistory < ApplicationRecord
  # belongs_to :user

  def self.search(params)
    # for datatable search
    filter = params[:search] || {}
    
    query_conditions = '1 = 1'
    query_hash = {}

    filter.except(:logged_at).each do |val|
      unless val[1].blank?
        query_conditions << " AND #{val[0]} like '%%#{val[1]}%%'"
      end
    end

    unless filter[:logged_at].blank?
      query_conditions.blank? ? query_conditions << "logged_at >= :logged_at" : query_conditions << " AND logged_at >= :logged_at"
      query_hash[:logged_at] = filter[:logged_at]
    end

    where(query_conditions, query_hash)
  end

  def self.pageTable(params)
    # per_page length
    length = params[:pagination][:pageSize]
    offset = (params[:pagination][:current] - 1) * params[:pagination][:pageSize]
    order = {}
    dir = 'desc'
    if params[:sortField].present?
      dir = 'asc' if params[:sortDirection] == 'ascend'
      order[params[:sortField]] = dir
    end
    search_data = search(params)
    # data total count
    count = search_data.count
    # which page
    data = search_data.order(order).limit(length).offset(offset)
    result = []

    data.each do |item|
      result.push(item.attributes.with_indifferent_access.merge({ id: item.id }))
    end

    return {
      total: count,
      results: result
    }
  end

  def self.create_from_request(request, params)
    begin
      if ENV["QA_EMAILS"].present? && ENV["QA_EMAILS"].include?(params[:user][:email])
        return
      end

      create({
        email: params[:user][:email],
        ip: request.remote_ip,
        logged_at: Time.now,
        user_agent: request.headers["User-Agent"],
        browser: params[:browser],
        os: params[:os],
        device_type: params[:device_type],
        timezone: params[:timezone],
        environment: ENV["ENV"],
        referer: request.referer
      }) if ENV["USER_HISTORY_ENABLE"] === "true"
    rescue => exception
      Rails.logger.error("save login history error -- #{exception.to_s}")
    end
  end

  def self.clear_histories
    begin
      where("DATE(logged_at) <= DATE(DATE_SUB(NOW(),INTERVAL 1 month))").destroy_all
    rescue => exception
      Rails.logger.error("clear login history error -- #{exception.to_s}")
    end
  end
end
