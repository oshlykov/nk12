class ProtocolsController < ApplicationController

before_filter :authenticate_user!, :except => [:index, :show]

  def new
    #@@voting_dictionary[1]
    #TODO [@uik.election]
    redirect_to :back unless @uik = Commission.find_by_id(params[:commission_id])
    @protocol = @uik.protocols.new
    #@protocol.votings = @votings
    if @protocol.save 
      #TODO election
      VOTING_DICTIONARY[1].count.times do |i| 
        v = @protocol.votings.new(:voting_dictionary_id => i+1) 
        v.save
      end
      redirect_to commission_protocol_url(@uik.id, @protocol.id)
    end

#    respond_to do |format| 
#      format.html # search.html.erb
#    end
  end

  def show
    #@uik = Commission.find_by_id!(params[:commission_id])
    #@protocol = Protocol.find_by_id!(params[:id])
    redirect_to :back unless @uik = Commission.find_by_id(params[:commission_id]) and @protocol = Protocol.find_by_id(params[:id])
  end
    
  def create
    #p = Protocol.new(params[:protocol])
  end  
  

  def update
    @protocol = Protocol.find_by_id!(params[:id])
    @protocol.votings.each do |v|
      v.votes = params[v.voting_dictionary_id.to_s]
      v.save 
    end
    redirect_to :back
  end
  
end
