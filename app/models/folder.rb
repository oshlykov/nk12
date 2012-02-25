class Folder < ActiveRecord::Base
  belongs_to :commission # Region
  belongs_to :created_by, :class_name => "User"
  belongs_to :user # Operator working with folder atm
  has_many :pictures

  validates_presence_of :commission_id

  attr_writer :election_id

  def election_id
    commission.election_id if commission
  end
end
