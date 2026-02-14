class BookingsController < ApplicationController
  def index
    @date = params[:date] ? Date.parse(params[:date]) : Date.today
    @teams = Team.order(:name)
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
    @lanes = (1..10).to_a
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

  def destroy
    @booking = Booking.find(params[:id])
    date = @booking.date
    @booking.destroy
    redirect_to root_path(date: date), notice: "Booking removed."
  end

  private

  def booking_params
    params.require(:booking).permit(:team_id, :lane, :date, :start_time)
  end

  def generate_time_slots
    slots = []
    # 8:00 AM to 9:00 PM = 53 slots at 15-min intervals
    (8..20).each do |hour|
      [0, 15, 30, 45].each do |min|
        slots << [hour, min]
      end
    end
    slots << [21, 0] # 9:00 PM is the last slot
    slots
  end
end
