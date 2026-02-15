class BookingsController < ApplicationController
  def index
    @date = params[:date] ? Date.parse(params[:date]) : (MeetSession.order(:date).first&.date || Date.today)
    @teams = Team.order(:abbreviation)
    @sessions = MeetSession.where(date: @date).order(:start_time)

    if @sessions.any?
      @bookings = Booking.where(date: @date).includes(:team)

      # Build a lookup: { [lane, hour, minute] => booking }
      @grid = {}
      @bookings.each do |booking|
        slots = booking.duration_slots
        slots.times do |i|
          slot_time = booking.start_time + (i * 15).minutes
          @grid[[booking.lane, slot_time.hour, slot_time.min]] = booking
        end
      end

      # Merge time slots from all sessions, deduplicate and sort
      @time_slots = @sessions.flat_map(&:time_slots).uniq.sort
      @lanes = (0..11).to_a.reverse
    end
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

    # Drag-and-drop sends lane + start_time — preserve the booking's duration
    if bp[:lane].present?
      attrs[:lane] = bp[:lane].to_i
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

    if @booking.update(attrs)
      redirect_to root_path(date: date), notice: "Booking updated successfully."
    else
      redirect_to root_path(date: date),
        alert: @booking.errors.full_messages.join(", ")
    end
  end

  def destroy
    @booking = Booking.find(params[:id])
    date = @booking.date
    @booking.destroy
    redirect_to root_path(date: date), notice: "Booking removed."
  end

  def clear
    date = params[:date] ? Date.parse(params[:date]) : (MeetSession.order(:date).first&.date || Date.today)
    count = Booking.where(date: date).delete_all
    redirect_to root_path(date: date), notice: "#{count} booking(s) cleared for #{date.strftime('%B %d, %Y')}."
  end

  private

  def booking_params
    params.require(:booking).permit(:team_id, :lane, :date, :start_time, :end_time, :name, :phone)
  end
end
