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

  def get_full_karik
    option = {:col_sep => ";", :encoding => "WINDOWS_1251"}
    FasterCSV.open( './public/uploads/csv/full_karik.csv', "w", option) do |csv|
      protocols = Protocol.includes(:commission).where("commission_id >= 200000 and priority = 1")
      protocols.each do |p|
        csv << [p.commission.name, p.commission.root.name, p.v19, "", p.v20, "", p.v21, "", p.v22, "", p.v23, ""].flatten.compact
      end
    end
    redirect_to  "/uploads/csv/full_karik.csv"
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
