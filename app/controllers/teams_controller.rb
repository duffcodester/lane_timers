class TeamsController < ApplicationController
  before_action :set_team, only: [:show, :edit, :update, :destroy]

  def index
    @teams = Team.left_joins(:bookings)
                 .select("teams.*, COUNT(bookings.id) AS bookings_count")
                 .group("teams.id")
                 .order(:name)
  end

  def new
    @team = Team.new
  end

  def create
    @team = Team.new(team_params)
    if @team.save
      redirect_to teams_path, notice: "Team created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @team.update(team_params)
      redirect_to teams_path, notice: "Team updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @team.bookings.where("date >= ?", Date.today).exists?
      redirect_to teams_path, alert: "Cannot delete team with future bookings."
    else
      @team.destroy
      redirect_to teams_path, notice: "Team deleted."
    end
  end

  private

  def set_team
    @team = Team.find(params[:id])
  end

  def team_params
    params.require(:team).permit(:name, :color, :coach, :address, :phone, :email)
  end
end
