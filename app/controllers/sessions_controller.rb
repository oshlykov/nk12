class SessionsController < ApplicationController
  def create
    user = User.find_by_email(params[:email])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id

      if params["remember_me"] == "1"
        cookies[:digest] = {:value => user.password_digest, :expires => Time.now + 3600000}
      else
        cookies[:digest] = nil
      end
      redirect_to (session[:ref] || root_path), :notice => "Рады вас видеть."
    else
      flash.now.alert = "Почта или пароль набраны не верно."
      render "new"
    end
  end

  def new
    if user = User.find_by_password_digest(cookies[:digest])
      session[:user_id] = user.id
      redirect_to (session[:ref] || root_path), :notice => "С возвращением #{user.name}"
    end
  end

  def destroy
    session[:user_id] = nil
    cookies[:digest] = nil
    redirect_to root_url, :notice => "Всего доброго."
  end

end