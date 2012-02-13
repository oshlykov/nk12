class User < ActiveRecord::Base
  has_secure_password
  ROLES = %w[admin region observer auth guest]
  def role?(base_role)
    ROLES.index(base_role.to_s) >= ROLES.index(role)
  end
  has_many :protocols
  has_many :pictures

  validates :email, :uniqueness => {:message => "Почтовый адрес уже используется", :case_sensitive => false}
  #validates :password, :confirmation => true
  #validates_confirmation_of :password, :message => "123"

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  #-devise :database_authenticatable, :registerable,
  #-       :recoverable, :rememberable, :trackable, :validatable

end
