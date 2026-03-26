class RegistrationsController < ApplicationController
  skip_before_action :require_login

  def new
    @user = User.new
    @clubs = Club.order(:priority, :name)
  end

  def create
    @user = User.new(signup_params)
    @user.role = :timer
    if @user.save
      session[:user_id] = @user.id
      redirect_to root_path, notice: "Account created successfully."
    else
      @clubs = Club.order(:priority, :name)
      render :new, status: :unprocessable_entity
    end
  end

  private

  def signup_params
    params.require(:user).permit(:name, :phone, :username, :password, :password_confirmation, :club_id)
  end
end
