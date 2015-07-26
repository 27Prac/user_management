class User < ActiveRecord::Base

  include Songkick::OAuth2::Model::ResourceOwner
  include Songkick::OAuth2::Model::ClientOwner
  module Constants
		PASSWORD_SALT = '$2a$10$7pGtu/4B.QStFjelud1ySO'.freeze
	    TOKEN_SALT = '$2a$10$rZbdUdO.wTtDh/EVJkErw.'.freeze
		SECRET_KEY = 'secret'.freeze
  end
  include Constants

  include StringNormalizer

  validates :password, :length => {:minimum => 5},
                       :presence => true,
                       :confirmation => true

  before_create :generate_authentity_token

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, :presence => true,
                    :uniqueness => true,
                    :format => { with: VALID_EMAIL_REGEX }


  def authenticate(confirmation_code)
    return false unless @user = User.find_by_id(self.id)

    if @user.confirmation_code == confirmation_code
      self.confirmation = true
      self.save
      true
    else
      false
    end
  end

  def authenticateuser(password)
	  return false unless @user = User.find_by_id(self.id)
	  require 'bcrypt'
	  passwordsalt=User::PASSWORD_SALT
	  password_hash = BCrypt::Engine.hash_secret(password, passwordsalt)
	  if @user.password == password_hash
		  true
	  else
		  false
	  end
  end

  private
  def generate_authentity_token
    require 'securerandom'
    self.authentity_token = normalize_token(SecureRandom.base64(64))
  end

  class << self
	  def get_id(token)
		  return nil if token.nil?
		  require 'encrypted_strings'
		  decrypt=token.decrypt(:symmetric, :algorithm => 'des-ecb', :password => User::SECRET_KEY)
		  user_json=JSON.parse(decrypt)
		  return user_json['id']
	  end
  end
end


