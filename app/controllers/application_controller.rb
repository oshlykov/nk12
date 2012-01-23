class ApplicationController < ActionController::Base
  protect_from_forgery
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  layout Proc.new { |controller| controller.request.xhr? ? nil : 'application' }

  def record_not_found
    render :file => "public/404.html", :status => 404, :layout => false
  end
end
