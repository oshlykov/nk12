module CommissionsHelper

#  def uik_votes(uik, index)
#    uik.votings.find_by_voting_dictionary_id(index).votes
    #uik.votings[index].votes
#  end

  def vote_class(p, index)

    if uik_protocol = p.commission.protocols.first and p.votings.find_by_voting_dictionary_id(index).votes ==  uik_protocol.votings.find_by_voting_dictionary_id(index).votes
      'green'
    else
      'red'
    end
  end

  def vote_class_uik(uik_protocol, index)
    #СДЕЛАТЬ Оптимизировать
    if p = uik_protocol.commission.protocols.where('priority > 0').first
      if p.votings.find_by_voting_dictionary_id(index).votes ==  uik_protocol.votings.find_by_voting_dictionary_id(index).votes
        'green'
      else
        'red'
      end
    else
      'gray'
    end
  end

end
