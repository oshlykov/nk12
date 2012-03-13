class Picture < ActiveRecord::Base

  include Rails.application.routes.url_helpers
  validates_presence_of :image
  belongs_to :protocol
  belongs_to :folder
  belongs_to :user
  
  before_save :vacate_folder
  after_destroy :remove_image!
  
  mount_uploader :image, PictureUploader

  default_scope order(:original_filename)

#  def own?(user)
#    user_id == user.id
# =>   end

  def rotate cw = true
    file_paths = [ self.image.current_path ] + self.image.versions.map{|k,v| v.current_path }
    file_paths.each do |fp| 
      img = MiniMagick::Image.open fp
      img.rotate(cw ? '90' : '-90')
      img.write fp
    end
  end

  protected
  def vacate_folder
    self.folder_id = nil if protocol_id
  end
end

=begin
module CarrierWave 
  class SanitizedFile 
    private 
      def file_with_base64_parser=(file) 
        file = file.with_indifferent_access if file.is_a?(Hash) 
        if file.is_a?(Hash) && file.has_key?(:filename) && file.has_key?(:content_type) && file.has_key?(:data) && !file.has_key?(:tempfile) 
          file[:tempfile] = StringIO.new(Base64.decode64(file.delete(:data))) 
        end 
        self.file_without_base64_parser = file 
      end 
      alias_method_chain :file=, :base64_parser 
  end 
end 
=end
