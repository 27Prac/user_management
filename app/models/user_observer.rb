class UserObserver < ActiveRecord::Observer
  include StringNormalizer

  def before_save(user)
    if user.new_record?
      encrypt_confirmation_code(user)
	  encrypt_password(user)
    end
  end

  def after_save(user)
	  begin
		  UserManagement::App.deliver(:confirmation, :confirmation_email, user.name,
									  user.email,
									  user.id,
									  user.confirmation_code) unless user.confirmation
	  rescue Exception => e
		  raise NoUserCreateException ,  { user: "Not able to send email - Error is #{e}." }
	  end
  end

  private
  def encrypt_confirmation_code(user)
    user.confirmation_code = set_confirmation_code(user)
  end

  def encrypt_password(user)
	  require 'bcrypt'
	  passwordsalt=User::PASSWORD_SALT
	  password_hash = BCrypt::Engine.hash_secret(user.password, passwordsalt)
	  user.password = password_hash
  end

  def set_confirmation_code(user)
    require 'bcrypt'
    salt = BCrypt::Engine.generate_salt
    confirmation_code = BCrypt::Engine.hash_secret(user.password, salt)
    normalize_token(confirmation_code)
  end
end

