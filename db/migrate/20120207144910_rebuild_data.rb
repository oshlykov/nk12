class RebuildData < ActiveRecord::Migration
  def up
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

    execute <<-SQLTEXT
	update protocols as p set 
	v1 =(select distinct votes from votings where protocol_id = p.id and voting_dictionary_id=1 ), 
	v2 =(select distinct votes from votings where protocol_id = p.id and voting_dictionary_id=2 ), 
	v3 =(select distinct votes from votings where protocol_id = p.id and voting_dictionary_id=3 ), 
	v4 =(select distinct votes from votings where protocol_id = p.id and voting_dictionary_id=4 ), 
	v5 =(select distinct votes from votings where protocol_id = p.id and voting_dictionary_id=5 ), 
	v6 =(select distinct votes from votings where protocol_id = p.id and voting_dictionary_id=6 ), 
	v7 =(select distinct votes from votings where protocol_id = p.id and voting_dictionary_id=7 ), 
	v8 =(select distinct votes from votings where protocol_id = p.id and voting_dictionary_id=8 ), 
	v9 =(select distinct votes from votings where protocol_id = p.id and voting_dictionary_id=9 ), 
	v10=(select distinct votes from votings where protocol_id = p.id and voting_dictionary_id=10), 
	v11=(select distinct votes from votings where protocol_id = p.id and voting_dictionary_id=11), 
	v12=(select distinct votes from votings where protocol_id = p.id and voting_dictionary_id=12), 
	v13=(select distinct votes from votings where protocol_id = p.id and voting_dictionary_id=13), 
	v14=(select distinct votes from votings where protocol_id = p.id and voting_dictionary_id=14), 
	v15=(select distinct votes from votings where protocol_id = p.id and voting_dictionary_id=15), 
	v16=(select distinct votes from votings where protocol_id = p.id and voting_dictionary_id=16), 
	v17=(select distinct votes from votings where protocol_id = p.id and voting_dictionary_id=17), 
	v18=(select distinct votes from votings where protocol_id = p.id and voting_dictionary_id=18), 
	v19=(select distinct votes from votings where protocol_id = p.id and voting_dictionary_id=19), 
	v20=(select distinct votes from votings where protocol_id = p.id and voting_dictionary_id=20), 
	v21=(select distinct votes from votings where protocol_id = p.id and voting_dictionary_id=21), 
	v22=(select distinct votes from votings where protocol_id = p.id and voting_dictionary_id=22), 
	v23=(select distinct votes from votings where protocol_id = p.id and voting_dictionary_id=23), 
	v24=(select distinct votes from votings where protocol_id = p.id and voting_dictionary_id=24), 
	v25=(select distinct votes from votings where protocol_id = p.id and voting_dictionary_id=25)
	where priority > 0
	SQLTEXT

	# where priority > 0 - special
	execute <<-SQLTEXT2
	drop table votings
	SQLTEXT2

  end

  def down
  end
end
