class UsersController < ApplicationController
  before_action :require_admin

  def index
    @users = User.order(:username)
  end

  def new
    @user = User.new
    @clubs = Club.order(:priority, :name)
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to users_path, notice: "User \"#{@user.username}\" created."
    else
      @clubs = Club.order(:priority, :name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @user = User.find(params[:id])
    @clubs = Club.order(:priority, :name)
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to users_path, notice: "User \"#{@user.username}\" updated."
    else
      @clubs = Club.order(:priority, :name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    user = User.find(params[:id])
    if user == current_user
      redirect_to users_path, alert: "You cannot delete your own account."
    else
      user.destroy
      redirect_to users_path, notice: "User \"#{user.username}\" deleted."
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :password, :password_confirmation, :role, :name, :phone, :club_id)
  end
end
