class Voting < ActiveRecord::Base
  belongs_to :protocol
  belongs_to :commission

  attr_accessor :name
  attr_accessor :main_role


  def name
    VOTING_DICTIONARY[protocol.commission.election_id][voting_dictionary_id]
  end

  def main_role?
    true
  end

end
