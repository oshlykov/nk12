class FoldersController < InheritedResources::Base
  before_filter :auth

  def create
    create! do |ok, nok|
      ok.html { redirect_to edit_resource_path }
      nok.html { render new_resource_path }
    end
  end

  def update
    update! { edit_resource_path }
  end

  def release
    resource.reserved_at = nil
    resource.save!
    redirect_to collection_path
  end

  protected
  def collection
    @reserved_folders ||= Folder.reserved
    @folders ||= Folder.available
  end

  def create_resource folder
    folder.created_by = current_user
    folder.save
  end
end
