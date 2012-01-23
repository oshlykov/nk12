class Voting < ActiveRecord::Base
  belongs_to :commission
#  belongs_to :@@voting_dictionary
#  validates_uniqueness_of :commission_id, :scope => :@@voting_dictionary_id

  @@voting_dictionary = []
  @@voting_dictionary[1] = []
  26.times do |i| 
    @@voting_dictionary[1][i]={} 
#    @@voting_dictionary[1][i][:main_role]= true
  end

  @@voting_dictionary[1][1][:name] = "Число избирательных бюллетеней, полученных участковой избирательной комиссией"
  @@voting_dictionary[1][2][:name] = "Число избирательных бюллетеней, выданных избирателям, проголосовавшим досрочно"
  @@voting_dictionary[1][3][:name] = "Число избирательных бюллетеней, выданных избирателям в помещении для голосования"
  @@voting_dictionary[1][4][:name] = "Число избирательных бюллетеней, выданных избирателям вне помещения для голосования"
  @@voting_dictionary[1][5][:name] = "Число погашенных избирательных бюллетеней"
  @@voting_dictionary[1][6][:name] = "Число избирательных бюллетеней в переносных ящиках для голосования"
  @@voting_dictionary[1][7][:name] = "Число избирательных бюллетеней в стационарных ящиках для голосования"
  @@voting_dictionary[1][8][:name] = "Число недействительных избирательных бюллетеней"
  @@voting_dictionary[1][9][:name] = "Число действительных избирательных бюллетеней"
  @@voting_dictionary[1][10][:name] = "Число открепительных удостоверений, полученных участковой избирательной комиссией"
  @@voting_dictionary[1][11][:name] = "Число открепительных удостоверений, выданных избирателям на избирательном участке"
  @@voting_dictionary[1][12][:name] = "Число избирателей, проголосовавших по открепительным удостоверениям на избирательном участке"
  @@voting_dictionary[1][13][:name] = "Число погашенных неиспользованных открепительных удостоверений"
  @@voting_dictionary[1][14][:name] = "Число открепительных удостоверений, выданных избирателям территориальной избирательной комиссией"
  @@voting_dictionary[1][15][:name] = "Число утраченных открепительных удостоверений"
  @@voting_dictionary[1][16][:name] = "Число утраченных избирательных бюллетеней"
  @@voting_dictionary[1][17][:name] = ""
  @@voting_dictionary[1][18][:name] = "Число избирательных бюллетеней, не учтенных при получении"
  @@voting_dictionary[1][19][:name] = "Политическая партия СПРАВЕДЛИВАЯ РОССИЯ"
  @@voting_dictionary[1][20][:name] = "Политическая партия Либерально-демократическая партия России"
  @@voting_dictionary[1][21][:name] = "Политическая партия ПАТРИОТЫ РОССИИ"
  @@voting_dictionary[1][22][:name] = "Политическая партия Коммунистическая партия Российской Федерации"
  @@voting_dictionary[1][23][:name] = "Политическая партия Российская объединенная демократическая партия ЯБЛОКО"
  @@voting_dictionary[1][24][:name] = "Всероссийская политическая партия ЕДИНАЯ РОССИЯ"
  @@voting_dictionary[1][25][:name] = "Всероссийская политическая партия ПРАВОЕ ДЕЛО"



  attr_accessor :name
  attr_accessor :main_role

  def name
    @name = @@voting_dictionary[commission.election_id][voting_dictionary_id][:name]
    #
    #
  end

  def main_role?
  	true
  end

end
