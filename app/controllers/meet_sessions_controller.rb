class MeetSessionsController < ApplicationController
  before_action :set_meet_session, only: [:edit, :update, :destroy, :duplicate]

  def index
    @meet_sessions = MeetSession.order(:date, :start_time)
  end

  def new
    last_session = MeetSession.order(:date, :end_time).last
    if last_session
      @meet_session = MeetSession.new(
        date: last_session.date,
        start_time: last_session.end_time,
        end_time: last_session.end_time + 1.hour
      )
    else
      @meet_session = MeetSession.new(
        start_time: Time.zone.parse("08:00"),
        end_time: Time.zone.parse("09:00")
      )
    end
  end

  def create
    @meet_session = MeetSession.new(meet_session_params)
    if @meet_session.save
      redirect_to meet_sessions_path, notice: "Session created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @meet_session.update(meet_session_params)
      redirect_to meet_sessions_path, notice: "Session updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def duplicate
    new_session = @meet_session.dup
    new_session.start_time = @meet_session.start_time + 1.hour
    new_session.end_time = @meet_session.end_time + 1.hour
    if new_session.save
      redirect_to meet_sessions_path, notice: "Session duplicated successfully."
    else
      redirect_to meet_sessions_path, alert: new_session.errors.full_messages.join(", ")
    end
  end

  def destroy
    if Booking.where(date: @meet_session.date).exists?
      redirect_to meet_sessions_path, alert: "Cannot delete session with existing bookings."
    else
      @meet_session.destroy
      redirect_to meet_sessions_path, notice: "Session deleted."
    end
  end

  private

  def set_meet_session
    @meet_session = MeetSession.find(params[:id])
  end

  def meet_session_params
    params.require(:meet_session).permit(:name, :date, :start_time, :end_time, :closed, :break_period)
  end
end
