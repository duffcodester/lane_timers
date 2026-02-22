class UserController < ApplicationController
  def edit
  end

  def update
    attrs = { username: params[:username] }

    if params[:password].present?
      if params[:password] != params[:password_confirmation]
        flash.now[:alert] = "New password and confirmation do not match."
        return render :edit, status: :unprocessable_entity
      end
      attrs[:password] = params[:password]
    end

    if current_user.update(attrs)
      redirect_to users_path, notice: "Account updated."
    else
      flash.now[:alert] = current_user.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end
end
