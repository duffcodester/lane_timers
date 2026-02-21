class MeetsController < ApplicationController
  before_action :set_meet, only: [:show, :edit, :update, :destroy]

  def index
    @meets = Meet.order(:name)
  end

  def show
  end

  def new
    @meet = Meet.new
  end

  def create
    @meet = Meet.new(meet_params)
    if @meet.save
      redirect_to meets_path, notice: "Meet \"#{@meet.name}\" created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @meet.update(meet_params)
      redirect_to meets_path, notice: "Meet \"#{@meet.name}\" updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @meet.destroy
    redirect_to meets_path, notice: "Meet \"#{@meet.name}\" deleted."
  end

  private

  def set_meet
    @meet = Meet.find(params[:id])
  end

  def meet_params
    params.require(:meet).permit(:name, :location)
  end
end
