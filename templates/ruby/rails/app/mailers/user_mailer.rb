class UserMailer < ApplicationMailer
  layout 'mailer'

  def user_password(email)
    @email = email
    mail(to: email, subject: 'Utility Operation login failed.')
  end
end
