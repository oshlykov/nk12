class HomeController < ApplicationController
  def index
    @elections = Election.find(:all)
    @checked_count = Protocol.where('priority = 1').size
    @unchecked_count = Protocol.where('priority > 1').size
    @users_count = User.count
    # @commissions = Commission.roots
  end

  def show
    @commission = Commission.find(params[:id])
    @election = @commission.election
#    @commission
#    election.commissions.roots.where()
    # @commission = Commission.all(:include => :votings, :conditions => {:is_uik => false})
  end
end
