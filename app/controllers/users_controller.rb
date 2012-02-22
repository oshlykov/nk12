class UsersController < ApplicationController
  #-before_filter :authenticate_user!

before_filter :auth, :except => [:new, :create]

  def new
    @user = User.new
  end

  def create
    params[:user][:commission] = Commission.roots.where(:id => params[:user][:commission]).first if params[:user].include? "commission"
    @user = User.new(params[:user])
    @user.role = 'auth'
    if @user.save
      session[:user_id] = @user.id
      
      redirect_to root_url, :notice => "Рады вас видеть." and return 
    end
    respond_to do |format|
      format.html { render "new" }
    end
  end

  def show 
    @user = User.find params[:id]
  end

  def update
    current_user.role = params[:user][:role] if current_user.role == 'admin'
    current_user.name = params[:user][:name]
    current_user.commission = Commission.roots.where(:id => params[:user][:commission]).first if params[:user].include? "commission"
    current_user.save
    redirect_to :back
  end

end
