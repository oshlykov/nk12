class CommissionsController < ApplicationController
  def index
    @uiks = Commission.find :all, :joins => :comments
    # Commission.includes([:comments]).where(:is_uik=>true)
  end

  def show
    @commission = Commission.find(params[:id])
    @election = @commission.election
    if request.xhr?
    else
    end
  end

end
