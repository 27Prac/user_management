UserManagement::App.mailer :confirmation do

  CONFIRMATION_URL = "http://localhost:3000/confirm"

  email :confirmation_email do |name, email, id, link|
    from "slohia1111@gmail.com"
    subject "Please confirm your account"
    to email
    locals :name => name, :confirmation_link => "#{CONFIRMATION_URL}/#{id}/#{link}"
    render 'confirmation/confirmation_email'
  end
end

