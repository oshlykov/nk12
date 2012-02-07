class Commission < ActiveRecord::Base
  has_ancestry
  serialize :state
   
  belongs_to :election
  has_many :comments, :dependent => :destroy 
  has_many :protocols, :dependent => :destroy, :order => 'priority ASC'
  
end
