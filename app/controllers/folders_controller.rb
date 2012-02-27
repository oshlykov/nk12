class FoldersController < InheritedResources::Base
  before_filter :auth

  def create
    create! do |ok, nok|
      ok.html { redirect_to edit_resource_path }
      nok.html { render new_resource_path }
    end
  end

  protected
  def create_resource folder
    folder.created_by = current_user
    folder.save
  end
end
