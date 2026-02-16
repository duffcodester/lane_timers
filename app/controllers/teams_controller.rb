class TeamsController < ApplicationController
  before_action :set_team, only: [:show, :edit, :update, :destroy]

  SORTABLE_COLUMNS = {
    "name" => "teams.name",
    "abbreviation" => "teams.abbreviation",
    "coach" => "teams.coach",
    "address" => "teams.address",
    "phone" => "teams.phone",
    "email" => "teams.email",
    "hours" => "total_hours",
    "misc_expense" => "teams.misc_expense"
  }.freeze

  def index
    @teams = Team.left_joins(:bookings)
                 .select("teams.*, COALESCE(SUM(EXTRACT(EPOCH FROM (bookings.end_time - bookings.start_time)) / 3600.0), 0) AS total_hours")
                 .group("teams.id")

    if params[:search].present?
      q = "%#{params[:search]}%"
      @teams = @teams.where(
        "teams.name ILIKE :q OR teams.abbreviation ILIKE :q OR teams.coach ILIKE :q OR teams.address ILIKE :q OR teams.phone ILIKE :q OR teams.email ILIKE :q",
        q: q
      )
    end

    @sort_column = SORTABLE_COLUMNS[params[:sort]] ? params[:sort] : "name"
    @sort_direction = params[:direction] == "desc" ? "desc" : "asc"
    order_sql = "#{SORTABLE_COLUMNS[@sort_column]} #{@sort_direction}"
    @teams = @teams.order(Arel.sql(order_sql))
  end

  def export
    teams = Team.left_joins(:bookings)
                .select("teams.*, COALESCE(SUM(EXTRACT(EPOCH FROM (bookings.end_time - bookings.start_time)) / 3600.0), 0) AS total_hours")
                .group("teams.id")
                .order("teams.name ASC")

    bookings = Booking.includes(:team).order(:date, :lane, :start_time)

    package = Axlsx::Package.new
    wb = package.workbook

    # Teams sheet
    wb.add_worksheet(name: "Teams") do |sheet|
      header_style = sheet.styles.add_style(b: true, bg_color: "2C3E50", fg_color: "FFFFFF")
      currency_style = sheet.styles.add_style(num_fmt: 7)
      formula_style = sheet.styles.add_style(num_fmt: 7, b: true)
      sheet.add_row ["Name", "Abbreviation", "Coach", "Address", "Phone", "Email", "Hours", "Amount", "Misc Expenses", "Total"], style: header_style
      teams.each_with_index do |team, i|
        row = i + 2
        hours = team.total_hours.to_f
        sheet.add_row [team.name, team.abbreviation, team.coach, team.address, team.phone, team.email, "%.2f" % hours, hours * 12, team.misc_expense.to_f, "=H#{row}+I#{row}"],
          style: [nil, nil, nil, nil, nil, nil, nil, currency_style, currency_style, formula_style],
          escape_formulas: false
      end
    end

    # Bookings sheet
    wb.add_worksheet(name: "Bookings") do |sheet|
      header_style = sheet.styles.add_style(b: true, bg_color: "2C3E50", fg_color: "FFFFFF")
      sheet.add_row ["Date", "Lane", "Team", "Start Time", "End Time", "Duration (min)", "Name", "Phone"], style: header_style
      bookings.each do |b|
        duration = ((b.end_time - b.start_time) / 60).to_i
        sheet.add_row [
          b.date.strftime("%Y-%m-%d"),
          b.lane,
          b.team.abbreviation.presence || b.team.name,
          b.start_time.strftime("%l:%M %p").strip,
          b.end_time.strftime("%l:%M %p").strip,
          duration,
          b.name,
          b.formatted_phone
        ]
      end
    end

    send_data package.to_stream.read,
      filename: "lane_timers_export_#{Time.current.strftime('%Y-%m-%d_%H%M%S')}.xlsx",
      type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
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
    params.require(:team).permit(:name, :abbreviation, :color, :coach, :address, :phone, :email, :misc_expense)
  end
end
