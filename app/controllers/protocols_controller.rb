class ProtocolsController < ApplicationController

#-before_filter :authenticate_user!, :except => [:index, :show]
before_filter :auth, :except => [:index, :show]

  def new
    #@@voting_dictionary[1]
    #TODO [@uik.election]
    redirect_to :back unless @uik = Commission.find_by_id(params[:commission_id])
    protocol = @uik.protocols.new
    #@protocol.votings = @votings
    protocol.user = current_user
    
    # 100 > непроверенные протоколы
    # 0 - данные ЦИК
    # 1 - основной для сверки
    protocol.priority = @uik.protocols.count + 100
    if protocol.save 
      #TODO election
      VOTING_DICTIONARY[1].count.times do |i| 
        v = protocol.votings.new(:voting_dictionary_id => i+1) 
        v.save
      end
      redirect_to commission_protocol_url(@uik.id, protocol.id)
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

  def destroy
    @p = Protocol.find(params[:id])
    if @p.can_destroy?
      #destroy
    end
  end  
  

  def update
    @protocol = Protocol.find_by_id!(params[:id])
    uik_protocol = @protocol.commission.protocols.first
    conflict = false
    @protocol.votings.each do |v|
      v.votes = params[v.voting_dictionary_id.to_s]
      v.save 
      conflict = true if uik_protocol.votings.find_by_voting_dictionary_id(v.voting_dictionary_id).votes != v.votes
    end
    if @protocol.conflict != conflict
        @protocol.conflict = conflict
        uik_protocol.conflict = conflict if @protocol.priority == 1
        @protocol.save
    end
    redirect_to :back
  end
  
end
