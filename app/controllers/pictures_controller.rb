class PicturesController < ApplicationController

  before_filter :auth, :except => [:index, :show, :create]
  before_filter :get_protocol
  

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
