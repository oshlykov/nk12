class AddStateToCommission < ActiveRecord::Migration
  def change
    add_column :commissions, :state, :text
    #Система кэширования голосов
   
=begin
state = Hash.new
Commission.where(:conflict => 1).each do |c|
  state[:uik] = c.protocols[0].votings
  karik = c.protocols[1]
  
  conflict = false
  if karik.priority == 1
    state[:checked] = Array.new
    karik.votings.each_with_index do |v,i|
      state[:checked][i] = karik.send("v#{i+1}")
      conflict = true if c.state[:checked][i] != c.state[:uik][i] and i != 25
    end
  end
  c.conflict = conflict
  c.state = state
  c.save
end
    # Получение голосов
    Protocol.where('user_id > 0').each do |p|
      p.commission.votes_taken = 1
    end
=end

  end
end
