class BookingsController < ApplicationController
  PER_PAGE = 12

  SORTABLE_COLUMNS = {
    "club"       => "clubs.name",
    "date"       => "bookings.date",
    "lane"       => "bookings.lane",
    "start_time" => "bookings.start_time",
    "end_time"   => "bookings.end_time",
    "hours"      => "hours",
    "name"       => "bookings.name",
    "phone"      => "bookings.phone"
  }.freeze

  def list
    @sort_column    = SORTABLE_COLUMNS[params[:sort]] ? params[:sort] : "start_time"
    @sort_direction = params[:direction] == "desc" ? "desc" : "asc"
    order_sql       = "#{SORTABLE_COLUMNS[@sort_column]} #{@sort_direction}"

    scope = Booking.joins(:club)
                   .select("bookings.*, clubs.name AS club_name, clubs.abbreviation AS club_abbreviation, clubs.color AS club_color, EXTRACT(EPOCH FROM (bookings.end_time - bookings.start_time)) / 3600.0 AS hours")
                   .order(Arel.sql(order_sql))

    @search = params[:search].to_s.strip
    if @search.present?
      pattern = "%#{@search}%"
      scope = scope.where(
        "clubs.abbreviation ILIKE :q OR clubs.name ILIKE :q OR bookings.name ILIKE :q OR bookings.phone ILIKE :q",
        q: pattern
      )
    end

    @clubs = Club.order(:name)

    # filter_active distinguishes "no filter applied" from "no clubs selected"
    if params[:filter_active].present?
      @selected_club_ids = Array(params[:club_ids]).map(&:to_i)
      scope = scope.where(club_id: @selected_club_ids) if @selected_club_ids.any?
      scope = scope.none if @selected_club_ids.empty?
    else
      @selected_club_ids = @clubs.pluck(:id)
    end

    count_scope = Booking.joins(:club)
    if @search.present?
      pattern = "%#{@search}%"
      count_scope = count_scope.where(
        "clubs.abbreviation ILIKE :q OR clubs.name ILIKE :q OR bookings.name ILIKE :q OR bookings.phone ILIKE :q",
        q: pattern
      )
    end
    if params[:filter_active].present?
      count_scope = @selected_club_ids.any? ? count_scope.where(club_id: @selected_club_ids) : count_scope.none
    end

    @total_count  = count_scope.count
    @current_page = [params[:page].to_i, 1].max
    @total_pages  = [(@total_count.to_f / PER_PAGE).ceil, 1].max

    @bookings_list = scope.limit(PER_PAGE).offset((@current_page - 1) * PER_PAGE)
  end

  def index
    @min_date = MeetSession.minimum(:date)
    @max_date = MeetSession.maximum(:date)
    @date = params[:date] ? Date.parse(params[:date]) : (@min_date || Date.today)
    @clubs = Club.where(bookable: true).order(:abbreviation)
    @sessions = MeetSession.where(date: @date).order(:start_time)

    if @sessions.any?
      @bookings = Booking.where(date: @date).includes(:club)

      # Build a lookup: { [lane, sub_lane, hour, minute] => booking }
      @grid = {}
      @bookings.each do |booking|
        slots = booking.duration_slots
        slots.times do |i|
          slot_time = booking.start_time + (i * 15).minutes
          @grid[[booking.lane, booking.sub_lane, slot_time.hour, slot_time.min]] = booking
        end
      end

      # Merge time slots from all sessions, deduplicate and sort
      @time_slots = @sessions.flat_map(&:time_slots).uniq.sort
      @lanes = (0..11).to_a.reverse

      # Build column list: lanes 0 and 11 get one column, lanes 1-10 get A and B
      @columns = @lanes.flat_map do |lane|
        if [0, 11].include?(lane)
          [{ lane: lane, sub_lane: nil }]
        else
          [{ lane: lane, sub_lane: "A" }, { lane: lane, sub_lane: "B" }]
        end
      end

      # Map session start times to session info for the session column
      @session_starts = {}
      @sessions.each do |s|
        key = [s.start_time.hour, s.start_time.min]
        @session_starts[key] = { name: s.name, slots: s.time_slots.size, closed: s.closed?, break_period: s.break_period? }
      end

      # Track which slots are covered by a session rowspan (to skip rendering td)
      @session_covered = Set.new
      @sessions.each do |s|
        s.time_slots.each_with_index do |(h, m), i|
          @session_covered.add([h, m]) if i > 0
        end
      end

      # Track which time slots belong to closed or break sessions
      @closed_slots = Set.new
      @sessions.select { |s| s.closed? || s.break_period? }.each do |s|
        s.time_slots.each { |h, m| @closed_slots.add([h, m]) }
      end
    end
  end

  def edit
    @booking = Booking.find(params[:id])
    @clubs = Club.where(bookable: true).order(:abbreviation)
  end

  def create
    @booking = Booking.new(booking_params)
    if @booking.save
      redirect_to root_path(date: @booking.date), notice: "Lane booked successfully."
    else
      redirect_to root_path(date: @booking.date || Date.today),
        alert: @booking.errors.full_messages.join(", ")
    end
  end

  def update
    @booking = Booking.find(params[:id])
    date = @booking.date

    attrs = {}

    bp = booking_params

    # Drag-and-drop sends lane + sub_lane + start_time — preserve the booking's duration
    if bp[:lane].present?
      attrs[:lane] = bp[:lane].to_i
    end
    if bp.key?(:sub_lane)
      attrs[:sub_lane] = bp[:sub_lane].presence
    end
    if bp[:start_time].present?
      new_start = Time.zone.parse("#{date} #{bp[:start_time]}")
      duration = @booking.end_time - @booking.start_time
      attrs[:start_time] = new_start
      attrs[:end_time] = new_start + duration
    end

    # Edit modal may send end_time directly
    if bp[:end_time].present?
      attrs[:end_time] = Time.zone.parse("#{date} #{bp[:end_time]}")
    end

    # Edit modal sends name + phone
    attrs[:name] = bp[:name] if bp.key?(:name)
    attrs[:phone] = bp[:phone] if bp.key?(:phone)

    if params[:source] == "list"
      # Full update from the edit page
      if @booking.update(booking_edit_params)
        redirect_to list_bookings_path, notice: "Booking updated."
      else
        @clubs = Club.where(bookable: true).order(:abbreviation)
        render :edit, status: :unprocessable_entity
      end
    else
      # Partial update from drag-drop / schedule modal
      if @booking.update(attrs)
        redirect_to root_path(date: date), notice: "Booking updated successfully."
      else
        redirect_to root_path(date: date),
          alert: @booking.errors.full_messages.join(", ")
      end
    end
  end

  def destroy
    @booking = Booking.find(params[:id])
    date = @booking.date
    from_list = params[:source] == "list"
    @booking.destroy
    if from_list
      redirect_to list_bookings_path, notice: "Booking removed."
    else
      redirect_to root_path(date: date), notice: "Booking removed."
    end
  end

  def clear
    date = params[:date] ? Date.parse(params[:date]) : (MeetSession.order(:date).first&.date || Date.today)
    count = Booking.where(date: date).delete_all
    redirect_to root_path(date: date), notice: "#{count} booking(s) cleared for #{date.strftime('%B %d, %Y')}."
  end

  private

  def booking_params
    params.require(:booking).permit(:club_id, :lane, :sub_lane, :date, :start_time, :end_time, :name, :phone, :notes, :community_service)
  end

  def booking_edit_params
    params.require(:booking).permit(:club_id, :lane, :sub_lane, :date, :start_time, :end_time, :name, :phone, :notes, :community_service)
  end
end
