class Commission < ActiveRecord::Base
  has_ancestry
  serialize :state
   
  belongs_to :election
  has_many :comments, :dependent => :destroy 
  has_many :protocols, :dependent => :destroy, :order => 'priority ASC'
  has_many :watchers, :class_name => "User", :foreign_key => "commission_id"

  def update_csv( cik = false )
    return cik ? self.protocols.first.to_a : self.protocols.size - 1 if self.is_uik

    protocols_to_csv = self.children.map{ |child| child.update_csv }.flatten

    return false unless protocols_to_csv and protocols_to_csv.many?

    csv = if File.exist? self.path 
        if self.protocols.reorder("updated_at desc").first.updated_at > File.ctime (self.path)
            create_csv( cik ) 
        else
            File.read self.path
        end
    else
        create_csv( cik )
    end

    return csv
  end

  def create_csv( cik = false )
      translate = { "id" => "Номер уик", "created_at" => "Дата загрузки" }
      VOTING_DICTIONARY[self.election_id].map{|k,v| translate[ "v"+k.to_s ] = v }
      
      option = {:col_sep => ";", :encoding => "UTF-8"}
          
      text = FasterCSV.generate(option) do |csv|
            csv << [self.name]
            csv << translate.values
            ( cik ? self.protocols.first : self.protocols.size - 1 ).each do |protocol|
                csv << translate.map{|k,v| puts k; protocol.attributes[k] }
            end
      end
      File.write(self.path ,"w") {|f| f.write text }
      text
  end

private
  def path
    Rails.root.join( "public/uik_csv/"+(self.id || "recycle")+".csv")
  end
  
end
