module CommissionsHelper

  def uik_votes(uik, index)
    uik.votings.find_by_voting_dictionary_id(index).votes
  end

end
