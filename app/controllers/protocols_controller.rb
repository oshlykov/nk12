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
      #VOTING_DICTIONARY[1].count.times do |i| 
      #  v = protocol.votings.new(:voting_dictionary_id => i+1) 
      #  v.save
      #end
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
    respond_to do |format|
      unless can? :destroy, @p and @p.destroy
        flash[:error] = 'Протокол не удалён, обратитесь в тех поддержку (support@nk12.su)'
      end
      format.js
    end
  end  

  def update
    @protocol = Protocol.find_by_id!(params[:id]) 
    uik_protocol = @protocol.commission.protocols.first
    conflict = false
    @protocol.votings.each_with_index do |v,i|
      @protocol.send("v#{i+1}=", params["#{i+1}"])
      conflict = true if params[i+1] != uik_protocol.votings[i+1]
=begin - заполнение кэша
    if @protocol is 
    state = Hash.new
    state[:uik] = @protocol.votings
    uik_protocol
=end

    end
    if @protocol.conflict != conflict
      @protocol.conflict = conflict
      uik_protocol.conflict = conflict if @protocol.priority == 1
    end
    @protocol.save #fixme
    redirect_to :back
  end
  
end
