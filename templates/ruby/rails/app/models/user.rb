class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :timeoutable, :lockable and :omniauthable
  devise :lockable, :zxcvbnable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  before_update :check_password_changed

  has_many :password_histories
  after_update :store_digest
  # after_create :send_admin_mail

  validates :password, :unique_password => true

  validates :email,
            :uniqueness => {
              :case_sensitive => true
            }

  validates :username,
            :presence => true,
            :uniqueness => {
              :case_sensitive => false
            }

  has_many :visits, class_name: "Ahoy::Visit"
  has_many :events, class_name: "Ahoy::Event"
  has_many :users_roles, :dependent => :destroy
  has_many :roles, through: :users_roles
  # def self.current  
  #   Thread.current[:user]  
  # end
  
  # def self.current=(user)  
  #   raise(ArgumentError,  
  #       "Invalid user. Expected an object of class 'User', got #{user.inspect}") unless user.is_a?(User)  
  #   Thread.current[:user] = user  
  # end

  def self.generate_password
    Zxcvbn::Passgen.generate
  end
  
  # overwrite
  def active_for_authentication? 
    super && approved? 
  end 
  
  def inactive_message 
    approved? ? super : :not_approved
  end

  def self.send_reset_password_instructions(attributes={})
    recoverable = find_by_email(attributes[:email])
    if recoverable.present? && !recoverable.approved?
      raise I18n.t("devise.failure.not_approved")
    end
    super
  end

  def self.search(params)
    # for datatable search
    filter = params[:search] || {}
    
    query_conditions = ''
    query_hash = {}

    unless filter[:email].blank?
      query_conditions.blank? ? query_conditions << "email like :email" : query_conditions << " AND email like :email"
      query_hash[:email] = "%#{filter[:email]}%"
    end

    unless filter[:username].blank?
      query_conditions.blank? ? query_conditions << "username like :username" : query_conditions << " AND username like :username"
      query_hash[:username] = "%#{filter[:username]}%"
    end

    unless filter[:login_count].blank?
      query_conditions.blank? ? query_conditions << "sign_in_count = :login_count" : query_conditions << " AND sign_in_count = :login_count"
      query_hash[:login_count] = filter[:login_count]
    end

    unless filter[:last_login_date_min].blank?
      query_conditions.blank? ? query_conditions << "last_sign_in_at >= :last_login_date_min" : query_conditions << " AND last_sign_in_at >= :last_login_date_min"
      query_hash[:last_login_date_min] = filter[:last_login_date_min]
    end

    unless filter[:last_login_date_max].blank?
      query_conditions.blank? ? query_conditions << "last_sign_in_at <= :last_login_date_max" : query_conditions << " AND last_sign_in_at <= :last_login_date_max"
      query_hash[:last_login_date_max] = filter[:last_login_date_max]
    end

    unless filter[:last_login_ip].blank?
      query_conditions.blank? ? query_conditions << "last_sign_in_ip = :last_login_ip" : query_conditions << " AND last_sign_in_ip = :last_login_ip"
      query_hash[:last_login_ip] = filter[:last_login_ip]
    end

    unless filter[:active].blank?
      query_conditions.blank? ? query_conditions << "active like :active" : query_conditions << " AND active like :active"
      query_hash[:active] = filter[:active] == "true" ? true : false
    end

    {
      data: where(query_conditions, query_hash),
      count: where(query_conditions, query_hash).count
    }
  end
  
  def self.pageTable2(params)
    # per_page length
    length = params[:pagination][:page_size]
    offset = (params[:pagination][:page_index] - 1) * params[:pagination][:page_size]
    order = {}
    sorting = params[:sorting] || []
    sorting.each do |val|
      order[val[:key]] = val[:order]
    end

    search_data = search(params)
    # data total count
    count = search_data[:count]
    # which page
    data = search_data[:data].order(order).limit(length).offset(offset)
    result = []

    data.each do |item|
      result.push(item.attributes.with_indifferent_access.merge({ id: item.id }))
    end

    return {
      total: count,
      results: result
    }
  end

  def self.pageTable(params)
    # per_page length
    length = params[:pagination][:pageSize]
    offset = (params[:pagination][:current] - 1) * params[:pagination][:pageSize]

    search_data = search(params)
    # data total count
    count = search_data[:count]
    # which page
    data = search_data[:data].sanitized_order(params[:sortField], params[:sortDirection]).limit(length).offset(offset)
    result = []

    data.each do |item|
      temp = item.attributes.with_indifferent_access
      temp[:role_ids] = []
      item.roles.each do |role|
        temp[:role_ids] << role.id
      end

      result.push(temp)
    end

    return {
      total: count,
      results: result
    }
  end

  # def get_permit_operation_group
  #   permissions = []

  #   Permission.select(:code, :name)
  #     .joins(roles: :users)
  #     .where(users: { email: self.email }, parent_id: Permission.select(:id).where(name: 'OperationGroup').first.id)
  #     .each do |permission|
  #     permissions << permission.name
  #   end

  #   permissions.uniq
  # end

  def permissions
    permissions = []
    Permission.select(:code, :name)
      .joins(roles: :users)
      .where(users: { email: self.email })
      .each do |permission|
      permissions << permission.code
    end
    permissions.uniq
  end

  private

  def check_password_changed
    self.pass_changed = Time.now if changed.include? 'encrypted_password'
  end

  def store_digest
    if saved_change_to_encrypted_password?
      PasswordHistory.create(:user_id => self.id, :encrypted_password => encrypted_password)
    end
  end

  def send_admin_mail
    AdminMailer.new_user_waiting_for_approval(email).deliver
  end

end
