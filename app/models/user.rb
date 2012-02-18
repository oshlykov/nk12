class User < ActiveRecord::Base
  has_secure_password
  ROLES = %w[admin region observer auth guest]
  def role?(base_role)
    ROLES.index(base_role.to_s) >= ROLES.index(role)
  end
  has_many :protocols
  has_many :pictures
  belongs_to  :commission

  validates :email, :presence => true, 
                    :length => {:minimum => 6, :maximum => 254},
                    :uniqueness => {:message => "Почтовый адрес уже используется", :case_sensitive => false},
                    :format => {:with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i}
  validates :password, :confirmation => true
  validates_confirmation_of :password, :message => "Пароли должны совпадать!"

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  #-devise :database_authenticatable, :registerable,
  #-       :recoverable, :rememberable, :trackable, :validatable

  def name
    read_attribute(:name) || "Аноним"
  end

end
