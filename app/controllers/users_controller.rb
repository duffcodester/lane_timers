class UsersController < ApplicationController
  def index
    @users = User.order(:username)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to users_path, notice: "User \"#{@user.username}\" created."
    else
      render :new, status: :unprocessable_entity
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
    params.require(:user).permit(:username, :password, :password_confirmation)
  end
end
