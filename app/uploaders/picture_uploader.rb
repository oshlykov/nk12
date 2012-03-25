# encoding: utf-8

class PictureUploader < CarrierWave::Uploader::Base

  # Include RMagick or ImageScience support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick
  # include CarrierWave::ImageScience

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/_#{model.id / 100}/#{model.id}"
  end

  process :resize_to_limit => [2500,2500]
  process :watermark => Rails.root.join("app","assets","images", "watermark.png")
  process :convert => "jpg"

  version :thumb do
    process :resize_to_limit => [100,100]
    process :convert => "jpg"
  end

  version :preview do
    process :resize_to_limit => [600, 600]
    process :convert => "jpg"
  end

  
  def watermark(path_to_file)
    manipulate! do |img|
        logo = MiniMagick::Image.open(path_to_file)
        logo.resize "#{img[:width]}x#{img[:height]}"
        img = img.composite(logo, "jpg") {|c| c.gravity "Center"}
        logo.destroy!
        img
    end
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process :scale => [50, 50]
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
   def extension_white_list
     %w(jpg jpeg gif png bmp)
   end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  def filename
    if original_filename
      @@name ||= Digest::MD5.hexdigest(File.read(current_path))
      "nk12_su-#{@@name}.jpg"
    end
  end

end
