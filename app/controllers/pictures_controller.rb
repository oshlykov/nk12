class PicturesController < InheritedResources::Base
  belongs_to :protocol, :folder, :polymorphic => true, :optional => true

  before_filter :auth, :except => [:index, :show]

  def create
    if params.include? :login and params.include? :password
      #mobile upload
        if user = User.find_by_email(params[:email]) and user.authenticate(params[:password])
          
          # file = file.with_indifferent_access if file.is_a?(Hash) 
          # if file.is_a?(Hash) && file.has_key?(:filename) && 
          #   file.has_key?(:content_type) && file.has_key?(:data) && !file.has_key?(:tempfile) 
          # file[:tempfile] = StringIO.new(Base64.decode64(file.delete(:data)))       
        end
=begin
    print_r($_FILES);
    $heades_printed = print_r($_SERVER, true);

    $new_image_name = "namethisimage.MMMMM";
    move_uploaded_file($_FILES["file"]["tmp_name"], "/home/borki/public_html/67/sites/default/files/UploadedDocs/".$new_image_name);

    $myFile = "/home/borki/public_html/67/sites/default/files/UploadedDocs/headers";
    $fh = fopen($myFile, 'w');
    fwrite($fh, $heades_printed);
    fwrite($fh, print_r($_FILES, true));
    fclose($fh);
=end      
    end
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
