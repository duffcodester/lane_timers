class SettingsController < ApplicationController
  def update_teams_columns
    Setting.set("teams_columns", params[:columns].to_json)
    head :ok
  end
end
