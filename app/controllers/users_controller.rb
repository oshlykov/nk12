class UsersController < InheritedResources::Base
  before_filter :auth, :except => [:new, :create]

  def create
    create! do |ok, nok|
      ok.html { 
        session[:user_id] = resource.id
        redirect_to root_url, :notice => "Рады вас видеть." and return 
        redirect_to edit_resource_path 
      }
      nok.html { render new_resource_path }
    end
  end

  def update
    authorize! :edit, resource
    params[:user][:role] = nil unless current_user.role == 'admin'
    update! { edit_resource_path }
  end

  protected
  def create_resource user
    user.role = 'auth'
    user.save
  end
end
