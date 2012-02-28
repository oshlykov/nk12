class ProtocolsController < InheritedResources::Base

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
    
    #protocol.election_id = 1 #fix

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
    redirect_to root_url unless @protocol = Protocol.find_by_id(params[:id]) and (@uik = @protocol.commission)
  end

  def unfold
    build_resource
  end
    
  def create
    create! do |ok, nok|
      nok.html do
	render 'unfold'
      end
    end
  end  

  def destroy
    redirect_to :back unless @p = Protocol.find_by_id(params[:id])
    respond_to do |format|
      unless can?(:destroy, @p) and @p.destroy
        flash[:error] = 'Протокол не удалён, обратитесь в тех поддержку (support@nk12.su)'
      end
      format.js
    end
  end  

  def update  
    #ИСПРАВИТЬ если протокол проверен, то запрет редактирования
    @protocol = Protocol.find_by_id!(params[:id]) 
    unless can?(:update, @protocol)
      redirect_to :back, :notice => "У вас нет прав редактировать протокол"
      return
    end

    uik_protocol = @protocol.commission.protocols.first
    commission = @protocol.commission
    @protocol.source = params[:source]
    conflict = false
    @protocol.votings.each_with_index do |v,i|
      @protocol.send("v#{i+1}=", params["#{i+1}"])
      commission.state[:checked][i] = @protocol.send("v#{i+1}") if @protocol.priority == 1
      conflict = true if params[i+1] != uik_protocol.votings[i+1]
=begin - заполнение кэша
    if @protocol is 
    state = Hash.new
    state[:uik] = @protocol.votings
    uik_protocol
=end

      commission.conflict = conflict if @protocol.priority == 1 and commission.conflict != conflict
    end
    commission.save #fixme
    @protocol.save #fixme
    redirect_to :back
  end

  def checking
    @protocols = Protocol.where("priority >= 100 and created_at < ?", 1.hour.ago).limit(100).all(:order => "created_at")
    
    if can? :cheking, Protocol

    end
  end

  def check
    @protocol = Protocol.find_by_id!(params[:id])
    @commission = @protocol.commission
    respond_to do |format|
      if can? :check, @protocol
        unless @commission.protocols.where('priority = 1').first
          @protocol.priority = 1
          @commission.votes_taken = true
          @commission.state[:checked] = Array.new(VOTING_DICTIONARY[@commission.election_id].size)
          
          @protocol.votings.each_with_index do |v,i|
            @commission.state[:checked][i] = @protocol.send("v#{i+1}")
            if @commission.state[:uik][i] != @commission.state[:checked][i]
              @commission.conflict = true
            end
          end
          @commission.save
        else
          if p = Protocol.where("priority>=50 and priority<100 and commission_id = ?", @commission.id).order('priority DESC').first
            @protocol.priority = p.priority+1
          else
            @protocol.priority = 50
          end
        end
        flash[:error] = 'Ошибка удаления' unless @protocol.save
      end
      format.js
    end

  end
  
  protected
  def build_resource
    if params[:folder_id]
      @pictures = Folder.find(params[:folder_id]).pictures
    end
    super.folder_pics ||= []
    super
  end

  def create_resource protocol
    protocol.attach_to_uik_from params[:folder_id] if params[:folder_id]
    protocol.user = current_user
    protocol.save
  end
end
