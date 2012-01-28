class Picture < ActiveRecord::Base

  include Rails.application.routes.url_helpers
  validates_presence_of :image
  belongs_to :protocol
  belongs_to :user
  
  after_destroy :remove_image!
  
  mount_uploader :image, PictureUploader

#  def own?(user)
#    user_id == user.id
# =>   end
    
  def to_jq_upload
  {
    "name" => read_attribute(:avatar),
    "size" => image.size,
    "url" => image.url,
    "thumbnail_url" => image.thumb.url,
    "delete_url" => commission_protocol_picture_path(protocol.commission_id, protocol,  id),
    "delete_type" => "DELETE" 
   }
  end
end
