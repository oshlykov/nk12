class UsersController < ApplicationController
  #-before_filter :authenticate_user!

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      session[:user_id] = @user.id
      redirect_to root_url, :notice => "Рады вас видеть."
    end
  end

  def show
    @user = User.find(params[:id])

  end

end
