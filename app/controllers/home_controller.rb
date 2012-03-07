class HomeController < ApplicationController
  def index
    @elections = Election.find(:all)
    @checked_count_1 = Protocol.where('priority = 1 and commission_id < 200000').size
    @unchecked_count_1 = Protocol.where('priority > 1 and commission_id < 200000').size
    @checked_count_2 = Protocol.where('priority = 1 and commission_id >= 200000').size
    @unchecked_count_2 = Protocol.where('priority > 1 and commission_id >= 200000').size
#    @protocols_new = Protocol.joins('INNER JOIN commissions c ON c.id = Protocols.commission_id').where("priority = 1 and commission_id >=200000").limit(40).all(:order => "created_at")
    @protocols_new = Protocol.includes(:commission).where("priority = 1 and commission_id >=200000").limit(20).all(:order => "created_at")

    @users_count = User.count
  end
=begin
  def show
    @commission = Commission.find(params[:id])
    @election = @commission.election
#    @commission
#    election.commissions.roots.where()
    # @commission = Commission.all(:include => :votings, :conditions => {:is_uik => false})
  end
=end

  def uik_by
    @commissions_1 = Commission.where("name like ? and election_id = 1", '%№'+params[:id].to_s).map { |c| [c, c.root.name] }
    @commissions_2 = Commission.where("name like ? and election_id = 2", '%№'+params[:id].to_s).map { |c| [c, c.root.name] }
    if @commissions
      @commissions.sort! { |a,b| a[1] <=> b[1] }
    else
      flash[:notice] = "Участка с номером #{params[:id]} не найдено" 
    end
  end
end
