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

  PER_PAGE = 10

  def index
    base = Team.all

    if params[:search].present?
      q = "%#{params[:search]}%"
      base = base.where(
        "teams.name ILIKE :q OR teams.abbreviation ILIKE :q OR teams.coach ILIKE :q OR teams.address ILIKE :q OR teams.phone ILIKE :q OR teams.email ILIKE :q",
        q: q
      )
    end

    @sort_column = SORTABLE_COLUMNS[params[:sort]] ? params[:sort] : "name"
    @sort_direction = params[:direction] == "desc" ? "desc" : "asc"
    order_sql = "#{SORTABLE_COLUMNS[@sort_column]} #{@sort_direction}"

    columns_json = Setting.get("teams_columns")
    @column_prefs = columns_json ? JSON.parse(columns_json) : {}

    @total_count = base.count
    @current_page = [params[:page].to_i, 1].max
    @total_pages = [(@total_count.to_f / PER_PAGE).ceil, 1].max

    @teams = base.left_joins(:bookings)
                 .select("teams.*, COALESCE(SUM(EXTRACT(EPOCH FROM (bookings.end_time - bookings.start_time)) / 3600.0), 0) AS total_hours")
                 .group("teams.id")
                 .order(Arel.sql(order_sql))
                 .limit(PER_PAGE)
                 .offset((@current_page - 1) * PER_PAGE)
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

  def import
    file = params[:file]
    unless file
      redirect_to teams_path, alert: "Please select a CSV file."
      return
    end

    require "csv"
    created = 0
    updated = 0
    errors = []
    content = File.read(file.path).sub(/\A\xEF\xBB\xBF/, "")
    CSV.parse(content, headers: true, header_converters: :downcase) do |row|
      name = row["name"].presence
      next unless name

      attrs = {
        name: name,
        abbreviation: (row["abbreviation"] || row["abbr"]).presence,
        color: (row["color"]).presence || "#3498db",
        coach: (row["coach"] || row["coach name(s)"] || row["coach names"]).presence,
        address: row["address"].presence,
        phone: row["phone"].presence,
        email: row["email"].presence,
        misc_expense: (row["misc_expense"] || row["misc expense"]).presence
      }.compact

      team = Team.find_by(name: name)
      if team
        team.update(attrs)
        updated += 1
      else
        if Team.create(attrs).persisted?
          created += 1
        else
          errors << name
        end
      end
    end

    msg = "Imported #{created} new team(s)."
    msg += " Updated #{updated} existing team(s)." if updated > 0
    msg += " Failed: #{errors.join(', ')}." if errors.any?
    redirect_to teams_path, notice: msg
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
