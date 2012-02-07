class AddStateToCommission < ActiveRecord::Migration
  def change
    add_column :commissions, :state, :text
    #Система кэширования голосов
    state = Hash.new
    Commission.where("is_uik = ? and state is null", 1).each do |c|
      state[:uik] = c.protocols.first.votings
      c.state = state
      c.save
    end

    # Получение голосов
    Protocol.where('priority > 0').each do |p|
      p.commission.votes_taken = 1
    end
   
=begin
=end


#      c.votes_taken = (c.protocols.where('priority > 0').size>0)?1:0
=begin

    exp = Array.new
    state = Hash.new
    Commission.find_all_by_is_uik(1, :limit => 5).each do |c|
      state[:uik] = c.protocols.first.votings
      c.state = state
      c.votes_taken = (c.protocols.where('priority > 0').size>0)?1:0
      c.save

      #exp[]=state
    end
    File.open("/tmp/123.yml", 'w') do |out|
     YAML.dump(exp, out)
    end

    exp = Array.new
    state = Hash.new
    Commission.find_all_by_is_uik(1).each_with_index do |c,i|
      exp[i] = Hash.new
      exp[i]['id'] = c.id
      exp[i]['state'] = Hash.new
      exp[i]['state']['uik'] = c.protocols.first.votings
      exp[i]['votes_taken'] = (c.protocols.where('priority > 0').size>0)?1:0
    end
    File.open("./123.yml", 'w') do |out|
     YAML.dump(exp, out)
    end
=end
  end
end
