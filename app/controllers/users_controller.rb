class UsersController < ApplicationController
  before_action :signed_in_user, only: %i[index edit update destroy]
  before_action :correct_user, only: %i[edit update]
  before_action :admin_user, only: :destroy

  def index
    @users = User.paginate(page: params[:page])
  end

  def new
    @user = User.new
  end

  def create
    params.permit!
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      flash[:success] = 'Welcome to the Sample App!'
      redirect_to @user
    else
      render 'new'
    end
  end

  def update
    params.permit!
    @user = User.find(params[:id])
    if @user&.update_attributes(params[:user])
      sign_in @user
      flash[:success] = 'Profile updated'
      redirect_to @user
    else
      render 'edit'
    end
  end

  def show
    by_id
  end

  def edit
    by_id
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = 'User destroyed'
    redirect_to users_path
  end

  def admin_user
    redirect_to(root_path) unless current_user.admin?
  end

  private

  def by_id
    @user = User.find(params[:id])
  end

  def signed_in_user
    store_location
    redirect_to signin_path, notice: 'Please sign in.' unless signed_in?
  end

  def correct_user
    @user = User.find(params[:id])
    redirect_to root_path unless current_user?(@user)
  end
end
