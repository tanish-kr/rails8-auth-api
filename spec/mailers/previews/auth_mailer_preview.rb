# Preview all emails at http://localhost:3000/rails/mailers/auth_mailer
class AuthMailerPreview < ActionMailer::Preview
  def confirmation_email
    email = "dummy_user1@example.com"
    user = User.new(email: email)
    AuthMailer.confirmation_email(user)
  end
end
