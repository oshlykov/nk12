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

  def edit
    @user = User.find params[:id]
    redirect_to :back unless can? :edit, @user
  end

  def update
    if can? :edit, @user
      @user = User.find params[:id]
      @user.role = params[:user][:role] if @user.role == 'admin'
      @user.name = params[:user][:name]
      @user.commission = Commission.roots.where(:id => params[:user][:commission]).first if params[:user].include? "commission"
      @user.save
    end
    redirect_to :back
  end

end
