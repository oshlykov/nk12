class ApplicationController < ActionController::Base
  protect_from_forgery
#  force_ssl

#  protect_from_forgery
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  rescue_from CanCan::AccessDenied do |exception|
    Rails.logger.debug "Access denied on #{exception.action} #{exception.subject.inspect}"
  end

  layout Proc.new { |controller| controller.request.xhr? ? nil : 'application' }

  def record_not_found
    #render :file => "public/404.html", :status => 404, :layout => false
  end


  def current_ability
    @current_ability ||= Ability.new(current_user)
  end

  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = "Доступ не разрешен."
    redirect_to root_url
  end


  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
    #User.find(nil)
  end

private


  def auth
    unless login?
      session[:ref] = request.url
      redirect_to new_session_url, :alert => "Вам необходимо сначала войти"
    end
  end

  def login?
    !!current_user 
  end

  helper_method :current_user, :login?
end
