class PicturesController < InheritedResources::Base
  belongs_to :protocol, :folder, :polymorphic => true, :optional => true

  before_filter :auth, :except => [:index, :show]

  def create
    create! do |ok, nok|
      ok.js do
	render :json => resource.to_jq_upload, :content_type => 'text/html' 
      end
      nok.js do
	render :json => [{:error => "custom_failure"}], :status => 304 
      end
    end
  end

  def destroy
    raise 'Not authorized' unless can?(:destroy, resource)
    destroy! do |ok, nok|
      ok.js
    end
  end

  protected
  def create_resource pic
    pic.user = current_user
    pic.save
  end
end
