class SettingsController < ApplicationController
  def update_clubs_columns
    Setting.set("clubs_columns", params[:columns].to_json)
    head :ok
  end
end
