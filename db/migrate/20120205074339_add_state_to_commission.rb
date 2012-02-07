class AddStateToCommission < ActiveRecord::Migration
  def change
    add_column :commissions, :state, :text
    #Система кэширования голосов
   
=begin
  state = Hash.new
    Commission.where("is_uik = ? and state is null", 1).each do |c|
      state[:uik] = c.protocols.first.votings
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
