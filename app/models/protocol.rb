class Protocol < ActiveRecord::Base
  belongs_to :commission
  belongs_to :user
  
  has_many :pictures, :dependent => :destroy
  #default_scope :order => :priority

  def own?(user)
    user_id == user.id if user
  end

  def votings
    @election_id ||= commission.election_id
    VOTING_DICTIONARY[@election_id].each_with_index.map {|v,i| send("v#{i+1}")} 
  end

  def voting_name(vdi=1)
    #fix
    @election_id ||= protocol.commission.election_id
    VOTING_DICTIONARY[@election_id][(vdi)]
  end  
  
   
=begin
  def self.with_votes    
    self.includes(:votings,:voting_dictionaries)
  # .where("voting_dictionaries.main_role",true)
  end

  def get_names
    # self.election.voting_dictionaries.map(&:en_name)
  end

  def pct(target)
    10
    # self.votings.joins(:voting_dictionary).where(:voting_dictionary => {:en_name => target})
    # if self.send(target).to_i > 0
    #   if target == "poll"
    #     100 * self.valid_ballots.to_i/self.send(target).to_i
    #   else  
    #     100 * self.send(target).to_i/self.valid_ballots.to_i
    #   end
    # else
    #   0
    # end
  end
=end

end
