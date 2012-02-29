class Folder < ActiveRecord::Base
  RESERVE_TIMEOUT = 2.hours
  belongs_to :commission # Region
  belongs_to :created_by, :class_name => "User"
  belongs_to :user # Operator working with folder atm
  has_many :pictures, :dependent => :destroy

  scope :reserved, lambda {
    includes(:commission).where(
      :reserved_at => (RESERVE_TIMEOUT.ago..Time.now)).order 'commissions.name'
  }

  scope :available, lambda {
    where 'reserved_at is NULL or reserved_at < ?', RESERVE_TIMEOUT.ago
  }

  validates_presence_of :commission_id

  attr_writer :election_id

  def election_id
    commission.election_id if commission
  end
end
