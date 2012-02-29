module CommissionsHelper

#  def uik_votes(uik, index)
#    uik.votings.find_by_voting_dictionary_id(index).votes
    #uik.votings[index].votes
#  end

  def vote_class(c, p, index)
    return 'green' if index == 26 
    if c.state and p.votings and c.state[:uik] and c.state[:uik][index-1] ==  p.votings[index-1]
      'green'
    else
      'red'
    end
  end

  def vote_class_uik(commission, index)
    #СДЕЛАТЬ Оптимизировать и индекс с 26 адаптировать к презедентским
    return 'gray' unless commission.votes_taken
    return 'green' if index == 26 
    if commission.state and commission.state[:uik] and commission.state[:checked] and commission.state[:checked] and commission.state[:uik][index-1] ==  commission.state[:checked][index-1]
      'green'
    else
      'red'
    end
  end

  def vote_color_uik(commission, index)
    #СДЕЛАТЬ Оптимизировать
    return 'gray' unless commission.votes_taken
    return 'green' if index == 26 
    if commission.state and commission.state[:uik] and commission.state[:checked] and commission.state[:checked] and commission.state[:uik][index-1] ==  commission.state[:checked][index-1]
      'green'
    else
      'red'
    end
  end

end
