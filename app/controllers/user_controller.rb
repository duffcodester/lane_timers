class UserController < ApplicationController
  def edit
    @clubs = Club.order(:priority, :name)
  end

  def update
    attrs = { username: params[:username], name: params[:name], phone: params[:phone], club_id: params[:club_id].presence }

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
