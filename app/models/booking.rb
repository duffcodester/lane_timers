class Booking < ApplicationRecord
  belongs_to :team

  validates :lane, presence: true, inclusion: { in: 1..12, message: "must be between 1 and 12" }
  validates :date, presence: true
  validates :start_time, presence: true
  validate :start_time_on_15_minute_boundary
  validate :start_time_within_range
  validate :no_overlapping_bookings

  DURATION_MINUTES = 60

  def end_time
    start_time + DURATION_MINUTES.minutes if start_time
  end

  private

  def start_time_on_15_minute_boundary
    return unless start_time
    unless start_time.min % 15 == 0
      errors.add(:start_time, "must be on a 15-minute boundary (XX:00, XX:15, XX:30, XX:45)")
    end
  end

  def start_time_within_range
    return unless start_time
    hour = start_time.hour
    min = start_time.min
    if hour < 8 || hour > 21 || (hour == 21 && min > 0)
      errors.add(:start_time, "must be between 8:00 AM and 9:00 PM")
    end
  end

  def no_overlapping_bookings
    return unless lane && date && start_time

    # A booking occupies start_time to start_time + 60 minutes.
    # Two bookings overlap if their time ranges intersect.
    # A new booking at time T conflicts with any existing booking whose
    # start_time is within (T - 45min) to (T + 45min) inclusive.
    conflicting_start = start_time - 45.minutes
    conflicting_end = start_time + 45.minutes

    scope = Booking.where(lane: lane, date: date)
      .where(start_time: conflicting_start..conflicting_end)
    scope = scope.where.not(id: id) if persisted?

    if scope.exists?
      errors.add(:base, "This slot overlaps with an existing booking on lane #{lane}")
    end
  end
end
