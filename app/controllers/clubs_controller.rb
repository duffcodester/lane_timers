class ClubsController < ApplicationController
  before_action :set_club, only: [:show, :edit, :update, :destroy]

  SORTABLE_COLUMNS = {
    "name" => "clubs.name",
    "abbreviation" => "clubs.abbreviation",
    "coach" => "clubs.coach",
    "address" => "clubs.address",
    "phone" => "clubs.phone",
    "email" => "clubs.email",
    "hours" => "total_hours",
    "booked" => "booked_hours",
    "complete" => "completed_hours"
  }.freeze

  PER_PAGE = 12

  def index
    base = Club.all

    if params[:search].present?
      q = "%#{params[:search]}%"
      base = base.where(
        "clubs.name ILIKE :q OR clubs.abbreviation ILIKE :q OR clubs.coach ILIKE :q OR clubs.address ILIKE :q OR clubs.phone ILIKE :q OR clubs.email ILIKE :q",
        q: q
      )
    end

    @sort_column = SORTABLE_COLUMNS[params[:sort]] ? params[:sort] : "name"
    @sort_direction = params[:direction] == "desc" ? "desc" : "asc"
    order_sql = "#{SORTABLE_COLUMNS[@sort_column]} #{@sort_direction}"

    columns_json = Setting.get("clubs_columns")
    @column_prefs = columns_json ? JSON.parse(columns_json) : {}

    @total_count = base.count
    @current_page = [params[:page].to_i, 1].max
    @total_pages = [(@total_count.to_f / PER_PAGE).ceil, 1].max

    @clubs = base.left_joins(:bookings)
                 .select("clubs.*, COALESCE(SUM(EXTRACT(EPOCH FROM (bookings.end_time - bookings.start_time)) / 3600.0), 0) AS total_hours, COALESCE(SUM(CASE WHEN bookings.name IS NOT NULL AND bookings.name != '' THEN EXTRACT(EPOCH FROM (bookings.end_time - bookings.start_time)) / 3600.0 ELSE 0 END), 0) AS booked_hours, COALESCE(SUM(CASE WHEN (bookings.date + bookings.end_time::time) < NOW() THEN EXTRACT(EPOCH FROM (bookings.end_time - bookings.start_time)) / 3600.0 ELSE 0 END), 0) AS completed_hours")
                 .group("clubs.id")
                 .order(Arel.sql(order_sql))
                 .limit(PER_PAGE)
                 .offset((@current_page - 1) * PER_PAGE)
  end

  def export
    clubs = Club.left_joins(:bookings)
                .select("clubs.*, COALESCE(SUM(EXTRACT(EPOCH FROM (bookings.end_time - bookings.start_time)) / 3600.0), 0) AS total_hours")
                .group("clubs.id")
                .order("clubs.name ASC")

    bookings = Booking.includes(:club).order(:date, :lane, :start_time)

    package = Axlsx::Package.new
    wb = package.workbook

    # Clubs sheet
    wb.add_worksheet(name: "Clubs") do |sheet|
      header_style = sheet.styles.add_style(b: true, bg_color: "2C3E50", fg_color: "FFFFFF")
      currency_style = sheet.styles.add_style(num_fmt: 7)
      formula_style = sheet.styles.add_style(num_fmt: 7, b: true)
      sheet.add_row ["Name", "Abbreviation", "Coach", "Address", "Phone", "Email", "Hours", "Amount"], style: header_style
      clubs.each_with_index do |club, i|
        hours = club.total_hours.to_f
        sheet.add_row [club.name, club.abbreviation, club.coach, club.address, club.phone, club.email, "%.2f" % hours, hours * 12],
          style: [nil, nil, nil, nil, nil, nil, nil, currency_style]
      end
    end

    # Bookings sheet
    wb.add_worksheet(name: "Bookings") do |sheet|
      header_style = sheet.styles.add_style(b: true, bg_color: "2C3E50", fg_color: "FFFFFF")
      sheet.add_row ["Date", "Lane", "Club", "Start Time", "End Time", "Duration (min)", "Name", "Phone"], style: header_style
      bookings.each do |b|
        duration = ((b.end_time - b.start_time) / 60).to_i
        sheet.add_row [
          b.date.strftime("%Y-%m-%d"),
          "#{b.lane}#{b.sub_lane}",
          b.club.abbreviation.presence || b.club.name,
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
      redirect_to clubs_path, alert: "Please select a CSV file."
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
        priority: row["priority"].presence&.to_i || 0
      }.compact

      club = Club.find_by(name: name)
      if club
        club.update(attrs)
        updated += 1
      else
        if Club.create(attrs).persisted?
          created += 1
        else
          errors << name
        end
      end
    end

    msg = "Imported #{created} new club(s)."
    msg += " Updated #{updated} existing club(s)." if updated > 0
    msg += " Failed: #{errors.join(', ')}." if errors.any?
    redirect_to clubs_path, notice: msg
  end

  def new
    @club = Club.new
  end

  def create
    @club = Club.new(club_params)
    if @club.save
      redirect_to clubs_path, notice: "Club created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @club.update(club_params)
      redirect_to clubs_path, notice: "Club updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @club.bookings.where("date >= ?", Date.today).exists?
      redirect_to clubs_path, alert: "Cannot delete club with future bookings."
    else
      @club.destroy
      redirect_to clubs_path, notice: "Club deleted."
    end
  end

  private

  def set_club
    @club = Club.find(params[:id])
  end

  def club_params
    params.require(:club).permit(:name, :abbreviation, :color, :coach, :address, :phone, :email, :priority)
  end
end
