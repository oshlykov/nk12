class User < ActiveRecord::Base
  has_secure_password
  ROLES = %w[admin region observer guest]
  def role?(base_role)
    ROLES.index(base_role.to_s) >= ROLES.index(role)
  end
  has_many :protocols
  has_many :pictures

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  #-devise :database_authenticatable, :registerable,
  #-       :recoverable, :rememberable, :trackable, :validatable

end
