class FoldersController < InheritedResources::Base
  before_filter :auth

  def create
    create! do |ok, nok|
      ok.html { redirect_to edit_resource_path }
      nok.html { render new_resource_path }
    end
  end

  def update
    authorize! :edit, resource
    update! { edit_resource_path }
  end

  def destroy
    authorize! :destroy, resource
    destroy!
  end

  def release
    if can? :unfold, resource
      resource.reserved_at = nil
      resource.save!
    else
      flash[:error] = 'С папкой уже работает другой пользователь'
    end
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
