module CommissionsHelper

#  def uik_votes(uik, index)
#    uik.votings.find_by_voting_dictionary_id(index).votes
    #uik.votings[index].votes
#  end

  def vote_class(p, index)

    if uik_protocol = p.commission.protocols.first and p.votings[index-1] ==  uik_protocol.votings[index-1]
      'green'
    else
      'red'
    end
  end

  def vote_class_uik(commission, index)
    #СДЕЛАТЬ Оптимизировать
    return 'gray' unless commission.votes_taken
    if commission.state['uik'][index-1] ==  commission.state['taken'][index-1]
      'green'
    else
      'red'
    end
  end

end
