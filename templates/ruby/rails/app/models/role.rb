#encoding: utf-8
class Role < ApplicationRecord
  has_many :users_roles, :dependent => :destroy
  has_many :users, through: :users_roles
  has_many :permissions_roles, :dependent => :destroy
  has_many :permissions, through: :permissions_roles

  validates :name,
            :presence => true,
            :uniqueness => true

  def self.get_related_permissions(params)
    if params[:id]
      selected_permissions = where(id: params[:id]).includes(:permissions)[0].permissions.pluck(:permission_id)
    else
      selected_permissions = []
    end

    transform_permissions = Proc.new do |p_hash|
      result = []
      p_hash.each do |parent, children|
        result << {
          key: parent.id,
          title: parent.name,
          children: transform_permissions.call(children)
        }
      end
      result
    end

    permissions = parent.const_get(:Permission).hash_tree

    {
      permissions: transform_permissions.call(permissions),
      checkedKeys: selected_permissions
    }
  end

  def self.search(params)
    # for datatable search
    filter = params[:search] || {}

    query_conditions = ""
    query_hash = {}

    unless filter[:name].blank?
      query_conditions.blank? ? query_conditions << "roles.name like :name" : query_conditions << " AND roles.name like :name"
      query_hash[:name] = "%#{filter[:name]}%"
    end

    unless filter[:code].blank?
      query_conditions.blank? ? query_conditions << "roles.code like :code" : query_conditions << " AND roles.code like :code"
      query_hash[:code] = "%#{filter[:code]}%"
    end

    where(query_conditions, query_hash)
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
      result.push(item.attributes.with_indifferent_access.merge({ id: item.id }))
    end

    return {
      total: count,
      results: result
    }
  end
end
