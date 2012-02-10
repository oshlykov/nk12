class CommissionsController < ApplicationController

#-before_filter :authenticate_user!, :except => [:index, :show]
before_filter :auth, :except => [:index, :show]

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
    #@checked_protocol = @protocols[1] if @protocols.count > 1
    @election = @commission.election
    if request.xhr?
    else
    end
  end

end
