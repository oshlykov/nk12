class CommissionsController < ApplicationController

#-before_filter :authenticate_user!, :except => [:index, :show]
  before_filter :auth, :except => [:index, :show, :get_csv]

  def index
    @uiks = Commission.find :all, :joins => :comments
    # Commission.includes([:comments]).where(:is_uik=>true)
  end

  def show
    @commission = Commission.find(params[:id])
    if @commission.is_uik
      @unchecked = @commission.protocols.where('priority >= 100')
      @checked = @commission.protocols.where('priority < 100')
    else
      @checked_count = @commission.subtree.where('votes_taken=1').size
    end
    @title = "#{@commission.name} — #{@commission.root.name}"
    #@checked_protocol = @protocols[1] if @protocols.count > 1
    @election = @commission.election
    if request.xhr?
    else
    end
  end

#FIXME move to watcher controller
  def add_watcher
    @commission = Commission.find(params[:id])
    if @commission and @commission.watchers.size < 5 and not @commission.watchers.include? current_user
      @commission.watchers << current_user
      UserMailer.notify_admin(current_user).deliver
      flash[:notice] = "Вы стали наблюдателем!"
    else
      flash[:error] = "Вы не можете стать наблюдателем этого участка!"
    end
    redirect_to commission_path(@commission)
  end

  def del_watcher
    current_user.update_attribute :commission_id, current_user.commission.root if current_user.commission
    redirect_to :back
  end

  def get_full_karik_2011
    x = Array.new
    Commission.includes(:protocols).where(:votes_taken => true).find_all_by_election_id(1).each_with_index do |c,i| 
      if c.state.include? :uik and c.state.include? :checked
        x << {
        :id => c.id,
        :name => c.name,
        :region => c.root.name,
        :uik => c.state[:uik],
        :karik => c.state[:checked]}
      end
    end
    option = {:col_sep => ";", :encoding => "WINDOWS_1251"}
    FasterCSV.open( './public/uploads/csv/full_karik_2011.csv', "w", option) do |csv|
      csv << ["УИК", "Область", "СР", "ЛДПР", "ПР", "КПРФ", "ЯБЛ", "ЕР", "ПД"]
      x.each do |ccc|
        csv << [ccc[:name], ccc[:region], ccc[:karik][1],ccc[:uik][1], ccc[:karik][2],ccc[:uik][2], ccc[:karik][3],ccc[:uik][3], ccc[:karik][4],ccc[:uik][4], ccc[:karik][5],ccc[:uik][5], ccc[:karik][6],ccc[:uik][6], ccc[:karik][7],ccc[:uik][7], ccc[:karik][8],ccc[:uik][8], ccc[:karik][9],ccc[:uik][9], ccc[:karik][10],ccc[:uik][10], ccc[:karik][11],ccc[:uik][11], ccc[:karik][12],ccc[:uik][12], ccc[:karik][13],ccc[:uik][13], ccc[:karik][14],ccc[:uik][14], ccc[:karik][15],ccc[:uik][15], ccc[:karik][16],ccc[:uik][16], ccc[:karik][17],ccc[:uik][17], ccc[:karik][18],ccc[:uik][18],ccc[:karik][19],ccc[:uik][19],ccc[:karik][20],ccc[:uik][20],ccc[:karik][21],ccc[:uik][21],ccc[:karik][22],ccc[:uik][22],ccc[:karik][23],ccc[:uik][23],ccc[:karik][24],ccc[:uik][24]].flatten.compact
      end
    end

    redirect_to  "/uploads/csv/full_karik_2011.csv"
  end

  def get_full_karik_2012
    x = Array.new
    Commission.includes(:protocols).where(:votes_taken => true).find_all_by_election_id(2).each_with_index do |c,i| 
      if c.state.include? :uik and c.state.include? :checked
        x << {
        :id => c.id,
        :name => c.name,
        :region => c.root.name,
        :uik => c.state[:uik],
        :karik => c.state[:checked]}
      end
    end
    option = {:col_sep => ";", :encoding => "WINDOWS_1251"}
    FasterCSV.open( './public/uploads/csv/full_karik_2012.csv', "w", option) do |csv|
      csv << ["УИК", "Область", "Жириновский(Протокол)", "Жириновский(ЦИК)", "Зюганов(Протокол)", "Зюганов(ЦИК)", " Миронов(Протокол)", "Миронов(ЦИК)", "Прохоров(Протокол)", "Прохоров(ЦИК)", "Путин(Протокол)", "Путин(ЦИК)"]
      x.each do |ccc|
        csv << [ccc[:name], ccc[:region], ccc[:karik][1],ccc[:uik][1], ccc[:karik][2],ccc[:uik][2], ccc[:karik][3],ccc[:uik][3], ccc[:karik][4],ccc[:uik][4], ccc[:karik][5],ccc[:uik][5], ccc[:karik][6],ccc[:uik][6], ccc[:karik][7],ccc[:uik][7], ccc[:karik][8],ccc[:uik][8], ccc[:karik][9],ccc[:uik][9], ccc[:karik][10],ccc[:uik][10], ccc[:karik][11],ccc[:uik][11], ccc[:karik][12],ccc[:uik][12], ccc[:karik][13],ccc[:uik][13], ccc[:karik][14],ccc[:uik][14], ccc[:karik][15],ccc[:uik][15], ccc[:karik][16],ccc[:uik][16], ccc[:karik][17],ccc[:uik][17], ccc[:karik][18],ccc[:uik][18],ccc[:karik][19],ccc[:uik][19],ccc[:karik][20],ccc[:uik][20],ccc[:karik][21],ccc[:uik][21],ccc[:karik][22],ccc[:uik][22]].flatten.compact
      end
    end

    redirect_to  "/uploads/csv/full_karik_2012.csv"
  end

  def get_candidates_karik_2011
    x = Array.new
    Commission.includes(:protocols).where(:votes_taken => true).find_all_by_election_id(1).each_with_index do |c,i| 
      if c.state.include? :uik and c.state.include? :checked
        x << {
        :id => c.id,
        :name => c.name,
        :region => c.root.name,
        :uik => c.state[:uik],
        :karik => c.state[:checked]}
      end
    end
    option = {:col_sep => ";", :encoding => "WINDOWS_1251"}
    FasterCSV.open( './public/uploads/csv/candidates_karik_2011.csv', "w", option) do |csv|
      csv << ["УИК", "Область", "СР", "ЛДПР", "ПР", "КПРФ", "ЯБЛ", "ЕР", "ПД"]
      x.each do |ccc|
        csv << [ccc[:name], ccc[:region], ccc[:karik][18],ccc[:uik][18],ccc[:karik][19],ccc[:uik][19],ccc[:karik][20],ccc[:uik][20],ccc[:karik][21],ccc[:uik][21],ccc[:karik][22],ccc[:uik][22],ccc[:karik][23],ccc[:uik][23],ccc[:karik][24],ccc[:uik][24]].flatten.compact
      end
    end

    redirect_to  "/uploads/csv/candidates_karik_2011.csv"
  end

  def get_candidates_karik_2012
    x = Array.new
    Commission.includes(:protocols).where(:votes_taken => true).find_all_by_election_id(2).each_with_index do |c,i| 
      if c.state.include? :uik and c.state.include? :checked
        x << {
        :id => c.id,
        :name => c.name,
        :region => c.root.name,
        :uik => c.state[:uik],
        :karik => c.state[:checked]}
      end
    end
    option = {:col_sep => ";", :encoding => "WINDOWS_1251"}
    FasterCSV.open( './public/uploads/csv/candidates_karik_2012.csv', "w", option) do |csv|
      csv << ["УИК", "Область", "Жириновский(Протокол)", "Жириновский(ЦИК)", "Зюганов(Протокол)", "Зюганов(ЦИК)", " Миронов(Протокол)", "Миронов(ЦИК)", "Прохоров(Протокол)", "Прохоров(ЦИК)", "Путин(Протокол)", "Путин(ЦИК)"]
      x.each do |ccc|
        csv << [ccc[:name], ccc[:region], ccc[:karik][18],ccc[:uik][18],ccc[:karik][19],ccc[:uik][19],ccc[:karik][20],ccc[:uik][20],ccc[:karik][21],ccc[:uik][21],ccc[:karik][22],ccc[:uik][22]].flatten.compact
      end
    end

    redirect_to  "/uploads/csv/candidates_karik_2012.csv"
  end

  def get_csv
    @commission = Commission.find(params[:id])
    if @commission.update_csv params[:cik] == "cik"
      redirect_to  "/uploads/csv/#{@commission.id}"+(params[:cik]=='cik' ? "_cik" : "")+".csv"
    else
      render :nothing => true, :status => 404
    end
  end

end
