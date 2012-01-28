class CommissionsController < ApplicationController

#-before_filter :authenticate_user!, :except => [:index, :show]
before_filter :auth, :except => [:index, :show]

  def index
    @uiks = Commission.find :all, :joins => :comments
    # Commission.includes([:comments]).where(:is_uik=>true)
  end

  def show
    @commission = Commission.find(params[:id])
    p = @commission.protocols
    @iik = p.first #fix 
    @checked_protocol = p[1] if p.count > 1
    @election = @commission.election
    if request.xhr?
    else
    end
  end

end
