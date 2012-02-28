class Protocol < ActiveRecord::Base
  belongs_to :commission
  belongs_to :user
  
  has_many :pictures, :dependent => :destroy

  after_create :load_pics

  attr_accessor :uik_num, :folder_pics

  validates_presence_of :commission_id

  #default_scope :order => :priority
=begin
  def own?(user)
    user_id == user.id if user
  end
=end
  def votings
    @election_id ||= commission.election_id
    VOTING_DICTIONARY[@election_id].each_with_index.map {|v,i| send("v#{i+1}")} 
  end

  def voting_name(vdi=1)
    #fix
    @election_id ||= protocol.commission.election_id
    VOTING_DICTIONARY[@election_id][(vdi)]
  end  

  def self.voting_name(vdi=1, election=nil)
    #fix
    if election
      @election_id = election 
    else
      @election_id ||= protocol.commission.election_id
    end
    VOTING_DICTIONARY[@election_id][(vdi)]
  end  

  def attach_to_uik_from folder_id
    errors.add(:uik_num, 'invalid') unless uik_num && uik_num.to_i > 0
    uik = Folder.find(folder_id).commission.descendants.
      first :conditions => ['name like ?', "%№#{uik_num}"]
    if uik
      self.commission = uik
    else
      errors.add :uik_num, 'not found'
    end
  end

  protected
  def load_pics
    if folder_pics
      @folder_pics.each do |pic_id|
	self.pictures << Picture.find(pic_id)
      end
    end
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
