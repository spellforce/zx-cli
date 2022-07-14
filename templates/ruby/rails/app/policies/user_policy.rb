#encoding: utf-8
class UserPolicy
  attr_reader :current_user, :user

  def initialize(current_user, user)
    @current_user = current_user
    @user = user
  end

  def admin?
    is_admin = false
    user.roles.each do |role|
      if role.code == "admin"
        is_admin = true
        break
      end
    end
    return is_admin
  end
end
