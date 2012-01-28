class PicturesController < ApplicationController

  #-before_filter :authenticate_user!, :except => [:index, :show]
  before_filter :auth, :except => [:index, :show, :create]
  before_filter :get_protocol

  
#  def index
#    @pictures = @protocol.pictures
#    render :json => @pictures.collect { |p| p.to_jq_upload }.to_json
#  end

  def create
    @picture = @protocol.pictures.new(params[:picture])
    @picture.user = current_user
    if @picture.save
      render :json => @picture.to_jq_upload, :content_type => 'text/html'
    else 
      render :json => [{:error => "custom_failure"}], :status => 304
    end
  end

   def destroy
    @picture = @protocol.pictures.find(params[:id])
#     @picture.destroy
#     render :json => true
    respond_to do |format|
      if @protocol.own?(current_user)
        unless @picture.destroy
          flash[:error] = 'Photo could not be deleted'
        end
      end
        format.js
    end
   end
  
private
  def  get_protocol
    redirect_to :back unless @protocol = Protocol.find_by_id(params[:protocol_id])
  end
  
end
