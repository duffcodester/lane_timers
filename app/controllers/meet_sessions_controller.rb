class MeetSessionsController < ApplicationController
  before_action :require_admin
  before_action :set_meet_session, only: [:edit, :update, :destroy, :duplicate]
  before_action :set_meets, only: [:new, :create, :edit, :update]

  PER_PAGE = 12

  def index
    @total_count = MeetSession.count
    @current_page = [params[:page].to_i, 1].max
    @total_pages = [(@total_count.to_f / PER_PAGE).ceil, 1].max

    @meet_sessions = MeetSession.includes(:meet)
                                .order(:date, :start_time)
                                .limit(PER_PAGE)
                                .offset((@current_page - 1) * PER_PAGE)
  end

  def new
    default_meet = Meet.order(created_at: :desc).first
    last_session = MeetSession.order(:date, :end_time).last
    if last_session
      @meet_session = MeetSession.new(
        meet: default_meet,
        date: last_session.date,
        start_time: last_session.end_time,
        end_time: last_session.end_time + 1.hour
      )
    else
      @meet_session = MeetSession.new(
        meet: default_meet,
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

  def set_meets
    @meets = Meet.order(:name)
  end

  def meet_session_params
    params.require(:meet_session).permit(:meet_id, :name, :date, :start_time, :end_time, :closed, :break_period)
  end
end
