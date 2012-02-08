class UsersController < ApplicationController
  #-before_filter :authenticate_user!

before_filter :auth

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    @user.role = 'guest'
    if @user.save
      session[:user_id] = @user.id
      
      redirect_to root_url, :notice => "Рады вас видеть."
    end
  end

  def show
    @user = User.find(params[:id])

  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    @user.role = params[:user][:role] if current_user.role == 'admin'
    @user.name = params[:user][:name]
    #@user.name = params[:user][:name]
    @user.save
    redirect_to :back
  end

end
