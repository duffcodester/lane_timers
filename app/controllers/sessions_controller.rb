class SessionsController < ApplicationController
  layout "login"
  skip_before_action :require_login

  def new
    redirect_to root_path if logged_in?
  end

  def create
    user = User.find_by(username: params[:username].to_s.downcase)
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      user.update_column(:last_seen_at, Time.current)
      redirect_to root_path, notice: "Logged in successfully."
    else
      flash.now[:alert] = "Invalid username or password."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session.delete(:user_id)
    redirect_to login_path, notice: "Logged out."
  end
end
