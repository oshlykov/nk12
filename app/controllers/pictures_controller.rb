class PicturesController < ApplicationController

  before_filter :get_protocol
  
#  def index
#    @pictures = @protocol.pictures
#    render :json => @pictures.collect { |p| p.to_jq_upload }.to_json
#  end

  def create
    @picture = @protocol.pictures.new(params[:picture])
#    if @picture.save
#      render :json => [@picture.to_jq_upload].to_json
#    else 
#      render :json => [{:error => "custom_failure"}], :status => 304
    if @picture.save
      respond_to do |format|
        format.js do
          render :partial => 'protocols/picture', :locals => {:picture => @picture}
        end
      end
    end
    
  end

   def destroy
     @picture = @protocol.pictures.find(params[:id])
#     @picture.destroy
#     render :json => true
    respond_to do |format|
      unless @picture.destroy
        flash[:error] = 'Photo could not be deleted'
      end
      format.js
     end
   end
  
private
  def  get_protocol
    redirect_to :back unless @protocol = Protocol.find_by_id(params[:protocol_id])
  end
  
end
