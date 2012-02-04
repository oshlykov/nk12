class Voting1 < ActiveRecord::Base
  #belongs_to :protocol
  #belongs_to :commission

  attr_accessor :name
  attr_accessor :main_role


  def name
    #fix
    @election_id ||= protocol.commission.election_id
    VOTING_DICTIONARY[@election_id][voting_dictionary_id]
  end

  def main_role?
    true
  end

end
