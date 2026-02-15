class BookingsController < ApplicationController
  def index
    @date = params[:date] ? Date.parse(params[:date]) : Date.new(2026, 3, 27)
    @teams = Team.order(:abbreviation)
    @bookings = Booking.where(date: @date).includes(:team)

    # Build a lookup: { [lane, hour, minute] => booking }
    @grid = {}
    @bookings.each do |booking|
      4.times do |i|
        slot_time = booking.start_time + (i * 15).minutes
        @grid[[booking.lane, slot_time.hour, slot_time.min]] = booking
      end
    end

    @time_slots = generate_time_slots
    @lanes = (0..11).to_a.reverse
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

    new_lane = params[:booking][:lane].to_i
    new_start_time = Time.zone.parse("#{date} #{params[:booking][:start_time]}")

    @booking.lane = new_lane
    @booking.start_time = new_start_time

    if @booking.save
      redirect_to root_path(date: date), notice: "Booking moved successfully."
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
    date = params[:date] ? Date.parse(params[:date]) : Date.new(2026, 3, 27)
    count = Booking.where(date: date).delete_all
    redirect_to root_path(date: date), notice: "#{count} booking(s) cleared for #{date.strftime('%B %d, %Y')}."
  end

  private

  def booking_params
    params.require(:booking).permit(:team_id, :lane, :date, :start_time)
  end

  def generate_time_slots
    slots = []
    # 8:00 AM to 8:00 PM
    (8..19).each do |hour|
      [0, 15, 30, 45].each do |min|
        slots << [hour, min]
      end
    end
    slots << [20, 0] # 8:00 PM display row
    slots
  end
end
