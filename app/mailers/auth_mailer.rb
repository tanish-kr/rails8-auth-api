class AuthMailer < ApplicationMailer
  def confirmation_email(user)
    @token = user.generate_confirmation_token
    mail(to: user.email, subject: "Please confirm your email address")
  end
end
