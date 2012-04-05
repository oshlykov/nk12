require 'net/http'
require 'nokogiri'
require 'open-uri'
require 'pp'

class Commission < ActiveRecord::Base
  has_ancestry
  serialize :state
   
  belongs_to :election
  has_many :comments, :dependent => :destroy 
  has_many :protocols, :dependent => :destroy, :order => 'priority ASC'
  has_many :watchers, :class_name => "User", :foreign_key => "commission_id"
#  scope :child_uik, lambda{|id| Commission.where(["ancestry like ?", "%/#{id}/%"]).where(:is_uik => true) }

  default_scope order(:name)

  def update_csv cik = false
    commissions = Commission.descendants_of(self.id).where(:is_uik => true)

    return true if File.exist?(self.path( cik ? "_cik" : "" )) and commissions.maximum(:updated_at) < File.ctime(self.path( cik ? "_cik" : "" ))
    create_csv commissions, cik
  rescue Exception => e
    logger.error "[CSV ERROR] "+e.inspect
    return false
  end

  def create_csv( childs, cik = false )
    option = {:col_sep => ";", :encoding => "WINDOWS_1251"}
        
    FasterCSV.open( self.path( cik ? "_cik" : "" ), "w", option) do |csv|

      csv << [self.name]
      csv << [ "Регион", "Номер уик", "Дата загрузки" ] + VOTING_DICTIONARY[self.election_id].values
#      Commission.roots(:election_id => 1).each do |r|
      rootid = childs.first.root.id
#      childs = r
 #     rootid = r.root.id

      childs.each do |child|
#      childs.descendants.where(:is_uik => 1, :votes_taken => 1).all.each do |child|
        if child.state and state = child.state[ cik ? :uik : :checked ]
          csv << [rootid, child.name, child.updated_at, state ].flatten.compact 
        end
      end

#      end

    end
  end

  def path postfix = ''
    Rails.root.join( "public/uploads/csv/"+(self.id.to_s || "recycle")+"#{postfix}.csv")
  end

  def refresh_summary recursive = true
    self.state ||= {}
    state[:summary] = Commission.get_summary children, election_id
    save!
    parent.refresh_summary if parent && recursive
  end

  def check_summary
    unless
     state && state[:summary] && state[:summary][:cik] &&
      state[:summary][:cik][VOTING_DICTIONARY_SHORT[election_id].size] &&
      state[:summary][:frauds] && state[:summary][:trusty] &&
      state[:summary][:trusty][VOTING_DICTIONARY_SHORT[election_id].size]
      refresh_summary false
    end
  end

  def self.get_summary sum_scope, election_id
    cik = {}
    trusty = {}
    frauds = 0
    fields_range = (1..VOTING_DICTIONARY_SHORT[election_id].size)
    fields_range.each do |i|
      cik[i] = 0
      trusty[i] = 0
    end
    sum_scope.each do |child|
      if child.is_uik?
	if protocol = child.protocols.find_by_priority(0)
	  trusty_protocol = child.protocols.find_by_priority(1)
	  has_frauds = 0
	  fields_range.each do |i|
	    cik[i] += protocol.send("v#{i}") rescue nil
	    if trusty_protocol
              trusty[i] += trusty_protocol.send("v#{i}") rescue nil
	      if trusty_protocol.send("v#{i}") != protocol.send("v#{i}")
                has_frauds = 1 
              end
            else
              trusty[i] += protocol.send("v#{i}") rescue nil
	    end
	  end
	  frauds += has_frauds
	end
      else
	child.check_summary
	fields_range.each do |i|
          cik[i] += (child.state[:summary][:cik][i] || 0)
          trusty[i] += (child.state[:summary][:trusty][i] || 0)
        end
	frauds += child.state[:summary][:frauds]
      end
    end
    {:cik => cik, :trusty => trusty, :frauds => frauds}
  end

################################################################################################################################################
################################################################################################################################################
################################################################################################################################################
################################################################################################################################################
################################################################################################################################################
################################################################################################################################################
################################################################################################################################################
################################################################################################################################################
################################################################################################################################################
################################################################################################################################################
################################################################################################################################################
################################################################################################################################################
################################################################################################################################################
################################################################################################################################################

  def self.url_normalize(url)
    host = url.match(".+\:\/\/([^\/]+)")[1]
    path = url.partition(host)[2] || "/"
    begin
      n=nil
      while n == nil or n == ""
        n = Net::HTTP.get(host, path)
        sleep 1
      end
      return n
    rescue Timeout::Error
      print "timeout-error - sleeping 5 seconds"
      sleep 1
      url_normalize(url)
    end
  end

#Commission.get_children(200076)

  def self.get_children(parent_commission, url = '', hierarchy = '')
    return true if hierarchy.count("/") > 6
    #идем по урл, забираем html селект или переходим на сайт субъекта
    url = parent_commission.url
    agent = Nokogiri::HTML(url_normalize(url), nil, 'Windows-1251')
    
    #Есть особые страницы которые переводят на такую-же портальную страницу, но региона. Если мы на такой, то подменяем её внутренней
    agent.search("a").each do |href|
      if (href.content.to_str == "сайт избирательной комиссии субъекта Российской Федерации")
        return parent_commission.destroy if Commission.find_by_url href['href']
        parent_commission.url = href['href']
        parent_commission.save
        url = parent_commission.url
        agent = Nokogiri::HTML(url_normalize(url), nil, 'Windows-1251')
      end
    end

    agent.search("a").search("a").each do |href|
      if (href.content.to_str == "Результаты выборов" or href.content.to_str == "Итоги голосования")
        parent_commission.voting_table_url = href['href']
        parent_commission.save
      end
    end

    agent.search("select option").each do |option|
      if option['value']
        name = option.content.gsub(/^\d+ /,'')
        unless child = Commission.find_by_url(option['value'])
          child = parent_commission.children.create(:name => name, :url => option['value'], :is_uik => name.include?("УИК"), :election_id => parent_commission.election_id)
        end

        if name.include?("УИК")
          #ставим флаг, что коммиссия содержит уики
          parent_commission.update_attributes(:uik_holder => true)                                     
        else
          print "Taken: #{name}\n"
        end                    
        get_children(child, '', "#{hierarchy}/#{child.name.to_s}")
      end
    end
  rescue 
    return false
  end

  def self.voting_table(commission)
    return unless commission.voting_table_url and commission.protocols.find_by_priority(0) == nil
    agent_inner = Nokogiri::HTML(url_normalize(commission.voting_table_url), nil, 'Windows-1251')
    p = commission.protocols.build :priority => 0, :user_id => 0 if agent_inner
    agent_inner.xpath('//table/tr').collect do |row|
      tds = row.xpath('td')
      if (tds.first.text.to_i > 0) and VOTING_DICTIONARY[commission.election_id].has_key?(tds.first.text.to_i)
        p.send("v#{tds.first.text.to_i}=", tds.last.first_element_child().text.to_i)
      end
    end
    p.save
    commission.state ||= Hash.new
    commission.state[:uik] = p.votings
    return commission.save unless karik = commission.protocols.find_by_priority(1)
    #Обновление кэша
    conflict = false
    karik.votings.each_with_index do |v,i|
      # karik.size-1 так как неучитываем последгний столбец с кол заявлений
      conflict = true if commission.state[:checked][i] != commission.state[:uik][i] and i != karik.size-1 
    end
    commission.conflict = conflict
    commission.votes_taken = true
    commission.save

  rescue Exception => ex
    print "Error: #{ex}\n"
  end

################################################################################################################################################
################################################################################################################################################
################################################################################################################################################
################################################################################################################################################
################################################################################################################################################
################################################################################################################################################
################################################################################################################################################
################################################################################################################################################
################################################################################################################################################
################################################################################################################################################
################################################################################################################################################
################################################################################################################################################
################################################################################################################################################
################################################################################################################################################

## encoding: utf-8
=begin
#require 'yaml'

  # Executes block. Measures and prints the execution time in seconds
  def execute_and_measure_time
    start_tm = Time.now
    yield
    end_tm = Time.now

    print "Start time: "
    print_tm(start_tm)

    print "End time: "
    print_tm(end_tm)

    print "Total time spent: ", (end_tm - start_tm).to_f, " seconds\n"
  end

  # Prints time in the format DD/MM/YY HH:MM:SS
  def print_tm(tm)
      print tm.strftime("%d/%m/%y %H:%M:%S"), "; "
  end
  # Checks if the file fname exits. If it doesn't fetches the data from URL url and saves it to the file named fname
  # Returns the contents of the file
  def fetch_and_save(fname, url)
    begin
      # Fetching only if the file does not exist or is empty
      if( (!File.exists?(fname)) || (File.zero?(fname)) )
        print "Fetching ", fname, "\n"
        raw_html = url_normalize(url)
        File.open(fname, 'w') do |f|
          f.syswrite(raw_html)
          f.close
        end
      else
        raw_html = File.read(fname)
      end
    rescue => e
      print "('", fname, "') Was not able to get URL: \'", url, "\': ", e.message, "\n"
    end

    return raw_html
  end

# get commission and flag is_uik
# get votes
# get subcommission if need




  # Fetches and stores all the needed data from the commission
  # Recursively calls itself to handle sub-commissions
  def fetch_commissions(dir, url)
    return if /Regional\/Regional/ =~ dir
    if(!File.exists?(dir))
      mkdir(dir)
    end

    # Storing commission's URL in the file system
    url_fname = dir + '/url'
    if( (!File.exists?(url_fname)) || (File.zero?(url_fname)) )
      File.open(url_fname, 'w') do |f_url|
        f_url.puts(url)
        f_url.close
      end
    end

    # Storing commission's page in the file system
    raw_html = fetch_and_save(dir + '/about.html', url)
    agent = Nokogiri::HTML(raw_html, nil, 'Windows-1251')

    # Search for subcommissions to fetch the data from all of them
    commissions = {}
    agent.search("select option").each do |option|
      if option['value']
        name = option.content.gsub(/^\d+ /,'')
        commissions[name.strip] = option['value']
      end
    end

    # Looking for regional commission site
    agent.search("a").each do |href|
      if (href.content.to_str == "сайт избирательной комиссии субъекта Российской Федерации")
      # Commission name = "Regional"
      commissions['Regional'] = href['href']
      end
    end

    # Does the commission page contain a link to the election's results?
    agent.search("a").search("a").each do |href|
      if (href.content.to_str == "Результаты выборов")
        # Fetch the votes page and store in the commission's folder
        fetch_and_save(dir + '/votes.html', href['href'])
      end
    end

    # Starting Parallel fetch for subcommissions
    Parallel.each(commissions, :in_threads => 8){ |name, url| fetch_commissions(dir + '/' + name, url) }
  end

  desc "Clean raw html data directory"
  task :clean_raw_html => :environment do
    print "*** Cleaning '", inp_data_dir, "' directory\n"

    execute_and_measure_time { rm_rf(inp_data_dir) }
  end

  desc "Fetch raw HTML data from http://www.vybory.izbirkom.ru and put it on disk"
  task :fetch_raw_html => :environment do
    print "*** Fetching the data from http://www.vybory.izbirkom.ru to the directory '", inp_data_dir, "' ***\n"
    require 'net/http'
    require 'nokogiri'
    require 'open-uri'

    execute_and_measure_time {
      fetch_commissions(inp_data_dir, "http://www.vybory.izbirkom.ru/region/izbirkom?action=show&root_a=null&vrn=100100031793505&region=0&global=true&type=0&sub_region=0&prver=0&pronetvd=null")
    }
#2011      fetch_commissions(inp_data_dir, "http://www.vybory.izbirkom.ru/region/izbirkom?action=show&root_a=null&vrn=100100028713299&region=0&global=true&type=0&sub_region=0&prver=0&pronetvd=null")
#2012      fetch_commissions(inp_data_dir, "http://www.vybory.izbirkom.ru/region/izbirkom?action=show&root_a=null&vrn=100100031793505&region=0&global=true&type=0&sub_region=0&prver=0&pronetvd=null")
  end

  desc "Parse raw HTML data stored in the file system and put them to the database"
  task :import_to_db_from_raw => :environment do
    require 'net/http'
    require 'nokogiri'
    require 'open-uri'
    require 'pp'


    print "*** Importing the data from the directory'", inp_data_dir, "' to the database ***\n"

    execute_and_measure_time {
      # The code below is almost copy of grab:get task. Temporary solution. Not very effective in terms of execution time

      Rake::Task['grab:clean_up'].invoke
      @election = Election.create!(:name => "2012 - Выборы Президента Российской Федерации", :url => "http://www.vybory.izbirkom.ru/region/izbirkom?action=show&root_a=null&vrn=100100031793505&region=0&global=true&type=0&sub_region=0&prver=0&pronetvd=null")
#2011      @election = Election.create!(:name => "2012 - Выборы Президента Российской Федерации", :url => "http://www.vybory.izbirkom.ru/region/izbirkom?action=show&root_a=null&vrn=100100028713299&region=0&global=true&type=0&sub_region=0&prver=0&pronetvd=null")
#2012      @election = Election.create!(:name => "2012 - Выборы Президента Российской Федерации", :url => "http://www.vybory.izbirkom.ru/region/izbirkom?action=show&root_a=null&vrn=100100031793505&region=0&global=true&type=0&sub_region=0&prver=0&pronetvd=null")


     # Getting commission's page from the file system. No fetching/saving happens. As all the data is already in filesystem's cache
    raw_html = fetch_and_save(inp_data_dir + '/about.html', "http://www.vybory.izbirkom.ru/region/izbirkom?action=show&root_a=null&vrn=100100031793505&region=0&global=true&type=0&sub_region=0&prver=0&pronetvd=null")
#2011     raw_html = fetch_and_save(inp_data_dir + '/about.html', "http://www.vybory.izbirkom.ru/region/izbirkom?action=show&root_a=null&vrn=100100028713299&region=0&global=true&type=0&sub_region=0&prver=0&pronetvd=null")
#2012     raw_html = fetch_and_save(inp_data_dir + '/about.html', "http://www.vybory.izbirkom.ru/region/izbirkom?action=show&root_a=null&vrn=100100031793505&region=0&global=true&type=0&sub_region=0&prver=0&pronetvd=null")
    agent = Nokogiri::HTML(raw_html, nil, 'Windows-1251')

    agent.search("select option").each_with_index do |option,index|
     if (option['value'])
      name = option.content.gsub(/^\d+ /,'')
      commission = Commission.create!(:name => name.strip, :url => option['value'], :election_id => @election.id)
      print "Taken: #{option.content}\n"
     end
    end

    Parallel.each(Commission.all, :in_threads => 15){|commission| get_children_from_raw_html(inp_data_dir + '/' + commission.name, commission, commission.url)}
  }
  end

  # The function below is almost copy of get_children_from_raw_html. Temporary solution. Not very effective in terms of execution time
  def get_children_from_raw_html(dir, parent_commission, url)
    return if /Regional\/Regional/ =~ dir
    begin
      # Getting commission's page from the file system. No fetching/saving happens. As all the data is already in filesystem's cache
      agent = Nokogiri::HTML(fetch_and_save(dir + '/about.html', url), nil, 'Windows-1251')

      agent.search("a").search("a").each do |href|
        if (href.content.to_str == "Результаты выборов")
          parent_commission.voting_table_url = href['href']
          parent_commission.save
        end
      end

      agent.search("select option").each do |option|
        if option['value']
          name = option.content.gsub(/^\d+ /,'')
          child = parent_commission.children.create(:name => name.strip, :url => option['value'], :is_uik => name.include?("УИК"), :election_id => @election.id)
          if name.include?("УИК")
            #ставим флаг, что комиссия содержит уики
            parent_commission.update_attributes(:uik_holder => true)
          else
            print "Taken: #{name}\n"
          end
          get_children_from_raw_html(dir + '/' + child.name, child, option['value'])
        end
      end
      agent.search("a").each do |href|
         if (href.content.to_str == "сайт избирательной комиссии субъекта Российской Федерации")
            get_children_from_raw_html(dir + '/Regional', parent_commission, href['href'])
        end
      end
#2012      voting_table_from_raw_html(dir, parent_commission)
    rescue Exception => ex
      print "Error: #{ex}\n"
    end
  end

#  desc "Grab all the commissions out there from 4-dec elections"
#  task :get => :environment do        
  def task_get_enviroment
    Rake::Task['grab:clean_up'].invoke
    
    beginning_time = Time.now
    
    require 'net/http'
    require 'nokogiri'
    require 'open-uri'
    require 'pp'

    @election = Election.create!(:name => "2012 — Выборы Президента Российской Федерации", :url => "http://www.vybory.izbirkom.ru/region/izbirkom?action=show&root_a=null&vrn=100100031793505&region=0&global=true&type=0&sub_region=0&prver=0&pronetvd=null")

#2011    @election = Election.create!(:name => "Выборы депутатов Государственной Думы Федерального Собрания Российской Федерации шестого созыва", :url => "http://www.vybory.izbirkom.ru/region/izbirkom?action=show&root_a=null&vrn=100100028713299&region=0&global=true&type=0&sub_region=0&prver=0&pronetvd=null")
#2012    @election = Election.create!(:name => "2012 — Выборы Президента Российской Федерации", :url => "http://www.vybory.izbirkom.ru/region/izbirkom?action=show&root_a=null&vrn=100100031793505&region=0&global=true&type=0&sub_region=0&prver=0&pronetvd=null")

    agent = Nokogiri::HTML(open("http://www.vybory.izbirkom.ru/region/izbirkom?action=show&root_a=null&vrn=100100031793505&region=0&global=true&type=0&sub_region=0&prver=0&pronetvd=null"), nil, 'Windows-1251')
#2011    agent = Nokogiri::HTML(open("http://www.vybory.izbirkom.ru/region/izbirkom?action=show&root_a=null&vrn=100100028713299&region=0&global=true&type=0&sub_region=0&prver=0&pronetvd=null"), nil, 'Windows-1251')
#2012    agent = Nokogiri::HTML(open("http://www.vybory.izbirkom.ru/region/izbirkom?action=show&root_a=null&vrn=100100031793505&region=0&global=true&type=0&sub_region=0&prver=0&pronetvd=null"), nil, 'Windows-1251')
    agent.search("select option").each_with_index do |option,index|      
      if (option['value'])      
        commission = Commission.create!(:name => option.content,:url => option['value'], :election_id => @election.id)        
        print "Taken: #{option.content}\n"
        #get_children(commission,commission.url)        
      end
    end

    Parallel.each(Commission.all, :in_threads => 15){|commission| get_children(commission,commission.url)}    
    
    # print "\n-- data taken, taken votes --\n"
  end  

    # обходим рекурсивно все внутренние ссылки
    agent.search("a").each do |href|
       if (href.content.to_str == "сайт избирательной комиссии субъекта Российской Федерации")
          get_children(parent_commission,href['href'])
      end
    end

  def voting_table(commission)    
    if commission.voting_table_url
      begin            
        agent_inner = Nokogiri::HTML(url_normalize(commission.voting_table_url), nil, 'Windows-1251')          
        voting_table = Hash.new
        rows = agent_inner.xpath('//table/tr')
        details = rows.collect do |row|                            
          tds = row.xpath('td')
          if (tds.first.text.to_i > 0)   
            if @voting_dictionaries.has_key?(tds.first.text.to_i) 
              # добавляем голоса в коммисию
              
              commission.votings.build(:votes => tds.last.first_element_child().text.to_i, :voting_dictionary_id => @voting_dictionaries[tds.first.text.to_i])                             
              
            end 
          end              
        end        
        commission.votes_taken = true            
        commission.save                    
              
       rescue Exception => ex
          print "Error: #{ex}\n"
       end  
    end
  end

=end
#2012      voting_table(parent_commission)
#   rescue Exception => ex
#     print "Error: #{ex}\n"
#   end
end
