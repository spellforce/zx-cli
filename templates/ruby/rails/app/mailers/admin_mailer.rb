class AdminMailer < ApplicationMailer
  layout 'mailer'

  def new_user_waiting_for_approval(email)
    @email = email
    mail(to: ENV['ADMIN_EMAIL'], subject: 'New User Awaiting Admin Approval')
  end
end
