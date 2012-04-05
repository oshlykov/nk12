
#пользователи
us = User.all
option = {:col_sep => ";", :encoding => "windows-1251"}
FasterCSV.open( 'users-commissions.csv', "w", option) do |csv|
  csv << ["номер", "имя", "почта", "код уика", "название уика", "регион"]
  us.each do |u|
    csv << [u.id, u.name, u.email, u.commission_id, u.commission_id ? u.commission.name : "", u.commission_id ? u.commission.root.name : "" ].flatten.compact
  end
end

#Перенов изображений протоколов
src = Protocol.find 306850
dst = Protocol.find 306857
src.pictures.each do |pic|
  pic.protocol_id = dst.id
  pic.save
end

#уики
cs = Commission.find_all_by_election_id(1)
x = Array.new
cs.each_with_index do |c,i| 
  x[i] = Hash.new
  x[i][:id] = c.id
  x[i][:parent] = c.parent_id
  x[i][:name] = c.name
  option = {:col_sep => ";", :encoding => "WINDOWS_1251"}
  FasterCSV.open('exp-katya.csv', "w", option) do |csv|
    csv << ['id', 'parent', 'name']
    x.each do |ccc|
      csv << [ccc[:id], ccc[:parent], ccc[:name]].flatten.compact
    end
  end
end

# обновление хешей и приоритетов
state = Hash.new
Commission.find_all_by_votes_taken(1).each do |c|
  if c.protocols.size < 2
    c.votes_taken = 0
    c.conflict = 0
    c.save
  else
    state[:uik] = c.protocols[0].votings
    karik = c.protocols[1]
    if karik.priority <100 and karik.priority >=50
      karik.priority = 1
      karik.save
    end

    conflict = false
    if karik.priority == 1
      state[:checked] = Array.new
      karik.votings.each_with_index do |v,i|
        state[:checked][i] = karik.send("v#{i+1}")
        conflict = true if state[:checked][i] != state[:uik][i] and i != 25
      end
    end
    c.state = state
    c.save
  end
end

# загрузка структуры уиков
Commission.roots.each do |c|
  Commission.get_children(c)
end

#стягивание всех данных по голосованиям с сайта ЦИК
cs = Commission.where("voting_table_url IS NOT NULL and election_id=2").includes(:protocols)
Parallel.each(Commission.where("voting_table_url IS NOT NULL and election_id=2").includes(:protocols), :in_threads => 4){ |c| Commission.voting_table(c) }
#или
Commission.where("voting_table_url IS NOT NULL and election_id=2").includes(:protocols).each do |c| Commission.voting_table(c) end

#особое обновление, кеширования - разовый случай
Commission.where("election_id=2 and voting_table_url IS NOT NULL and state = '--- \n'").each do |commission|
  if commission.voting_table_url and uik = commission.protocols.find_by_priority(0)
    commission.state ||= Hash.new
    commission.state[:uik] = uik.votings
    if karik = commission.protocols.find_by_priority(1)
      
      commission.state[:checked] = karik.votings unless commission.state.include? :checked
      #Обновление кэша
      conflict = false
      karik.votings.each_with_index do |v,i|
        # karik.size-1 так как неучитываем последгний столбец с кол заявлений
        conflict = true if commission.state[:checked][i] != commission.state[:uik][i] and i != karik.votings.size-1 
      end
      commission.conflict = conflict
      commission.votes_taken = true
    end 
    commission.save
  end
end

#первичный обсчет итогов
Commission.roots.each { |c| c.refresh_summary }
