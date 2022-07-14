class Ahoy::Event < ApplicationRecord
  include Ahoy::QueryMethods

  self.table_name = "ahoy_events"

  belongs_to :visit
  belongs_to :user, optional: true

  def self.search(params)
    # identical
    query_conditions = ''
    query_hash = {}
    filter = params[:search] || {}

    unless filter[:email].blank?
      query_conditions.blank? ? query_conditions << 'users.email like :email' : query_conditions << ' AND users.email like :email'
      query_hash[:email] = "%#{filter[:email]}%"
    end

    unless filter[:name].blank?
      query_conditions.blank? ? query_conditions << 'ahoy_events.name like :name' : query_conditions << ' AND ahoy_events.name like :name'
      query_hash[:name] = "%#{filter[:name]}%"
    end

    unless filter[:properties].blank?
      query_conditions.blank? ? query_conditions << 'ahoy_events.properties like :properties' : query_conditions << ' AND ahoy_events.properties like :properties'
      query_hash[:properties] = "%#{filter[:properties]}%"
    end

    unless filter[:time_min].blank?
      query_conditions.blank? ? query_conditions << 'ahoy_events.time >= :time_min' : query_conditions << ' AND ahoy_events.time >= :time_min'
      query_hash[:time_min] = DateTime.parse(filter[:time_min])
    end

    unless filter[:time_max].blank?
      query_conditions.blank? ? query_conditions << 'ahoy_events.time <= :time_max' : query_conditions << ' AND ahoy_events.time <= :time_max'
      query_hash[:time_max] = DateTime.parse(filter[:time_max])
    end

    where(query_conditions, query_hash).includes(:user).references(:users)
  end

  def self.pageTable(params)
    # per_page length
    length = params[:pagination][:pageSize]
    offset = (params[:pagination][:current] - 1) * params[:pagination][:pageSize]

    search_data = search(params)
    # data total count
    count = search_data.count
    # which page
    data = search_data.sanitized_order(params[:sortField], params[:sortDirection]).limit(length).offset(offset)
    result = []

    data.each do |item|
      result.push(item.attributes.with_indifferent_access.merge({ id: item.id, email: item.user && item.user.email }))
    end

    return {
      total: count,
      results: result
    }
  end

  def self.get_summary
    total_count = self.all.count
    last_info = self.order('id desc').limit(1)[0]
    today_count = self.where('date(time) = curdate()').count
    month_count = self.where("DATE_FORMAT(time,'%Y%m') = DATE_FORMAT(CURDATE(),'%Y%m')").count

    return {
      total_count: total_count,
      today_count: today_count,
      month_count: month_count,
      last_info: {
        name: last_info[:name],
        email: last_info.user && last_info.user.email || 'N/A'
      }
    }.with_indifferent_access
  end
end
