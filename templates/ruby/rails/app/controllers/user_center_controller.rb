class UserCenterController < ApplicationController
  before_action :authenticate_user!
  before_action :check_user_login

  def reset_password
    user = current_user
    if user.valid_password?(params[:currentPassword])
      user.password = params[:password]
      user.save
      user.errors.messages[:password] << "recommended is: #{User.generate_password}" if user.errors.messages[:password].present?
      render_resource(user)
    else
      error!("Current password error!")
    end
  end

  def update_profile
    user = current_user
    user.username = params[:username]
    user.save!
    success_alert!('Update Success!')
  end

  def get_all_users
    users = User.all
    success!(users)
  end

  def info
    user = current_user.attributes.with_indifferent_access
    user[:permissions] = current_user.permissions
    success!(user)
  end
end
