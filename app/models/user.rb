class User < ActiveRecord::Base
  has_secure_password
  ROLES = %w[admin observer guest]
  has_many :protocols
  has_many :pictures

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  #-devise :database_authenticatable, :registerable,
  #-       :recoverable, :rememberable, :trackable, :validatable

end
