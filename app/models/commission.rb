class Commission < ActiveRecord::Base
  has_ancestry
  serialize :state
   
  belongs_to :election
  has_many :comments, :dependent => :destroy 
  has_many :protocols, :dependent => :destroy, :order => 'priority ASC'
  has_many :watchers, :class_name => "User", :foreign_key => "commission_id"
  scope :child_uik, lambda{|id| Commission.where(["ancestry like ?", "%#{id}%"]).where(:is_uik => true) }

  def update_csv cik = false
    commissions = Commission.child_uik self.id
    return true if File.exist?(self.path( cik ? "_cik" : "" )) and commissions.maximum(:updated_at) < File.ctime(self.path( cik ? "_cik" : "" ))
    create_csv commissions, cik
  rescue Exception => e
    logger.error "[CSV ERROR] "+e.inspect
    return false
  end

 def create_csv( childs, cik = false )
    
    option = {:col_sep => ";", :encoding => "UTF-8"}
        
    FasterCSV.open( self.path( cik ? "_cik" : "" ), "w", option) do |csv|
      csv << [self.name]
      csv << [ "Номер уик", "Дата загрузки" ] + VOTING_DICTIONARY[self.election_id].values
      childs.each do |child|
        if child.state and state = child.state[ cik ? :uik : :checked ]
          csv << [ child.name, child.updated_at, state ].flatten.compact 
        end
      end
    end
  end

  def path postfix = ''
    Rails.root.join( "public/uploads/csv/"+(self.id.to_s || "recycle")+"#{postfix}.csv")
  end
  
end
