class Booking < ApplicationRecord
  belongs_to :team

  validates :lane, presence: true, inclusion: { in: 0..11, message: "must be between 0 and 11" }
  validates :date, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validate :times_on_15_minute_boundary
  validate :end_time_after_start_time
  validate :minimum_duration
  validate :times_within_session
  validate :no_overlapping_bookings

  def duration_slots
    return 0 unless start_time && end_time
    ((end_time - start_time) / 15.minutes).to_i
  end

  private

  def times_on_15_minute_boundary
    if start_time && start_time.min % 15 != 0
      errors.add(:start_time, "must be on a 15-minute boundary")
    end
    if end_time && end_time.min % 15 != 0
      errors.add(:end_time, "must be on a 15-minute boundary")
    end
  end

  def end_time_after_start_time
    return unless start_time && end_time
    if end_time <= start_time
      errors.add(:end_time, "must be after start time")
    end
  end

  def minimum_duration
    return unless start_time && end_time && end_time > start_time
    if (end_time - start_time) < 15.minutes
      errors.add(:end_time, "booking must be at least 15 minutes")
    end
  end

  def times_within_session
    return unless date && start_time && end_time
    sessions = MeetSession.where(date: date)
    if sessions.empty?
      errors.add(:date, "has no session configured")
      return
    end
    booking_start = start_time.change(year: 2000, month: 1, day: 1)
    booking_end = end_time.change(year: 2000, month: 1, day: 1)
    within_any = sessions.any? do |session|
      session_start = session.start_time.change(year: 2000, month: 1, day: 1)
      session_end = session.end_time.change(year: 2000, month: 1, day: 1)
      booking_start >= session_start && booking_end <= session_end
    end
    unless within_any
      errors.add(:base, "booking must be within a session window")
    end
  end

  def no_overlapping_bookings
    return unless lane && date && start_time && end_time

    # Two bookings overlap if their time ranges intersect:
    # existing.start_time < new.end_time AND existing.end_time > new.start_time
    scope = Booking.where(lane: lane, date: date)
      .where("start_time < ? AND end_time > ?", end_time, start_time)
    scope = scope.where.not(id: id) if persisted?

    if scope.exists?
      errors.add(:base, "This slot overlaps with an existing booking on lane #{lane}")
    end
  end
end
