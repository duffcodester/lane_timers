class Booking < ApplicationRecord
  belongs_to :team

  validates :lane, presence: true, inclusion: { in: 0..11, message: "must be between 0 and 11" }
  validates :date, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validate :times_on_15_minute_boundary
  validate :end_time_after_start_time
  validate :minimum_duration
  validates :phone, format: { with: /\A\d{10}\z/, message: "must be a 10-digit number" }, allow_blank: true
  validate :no_overlapping_bookings
  validate :not_during_closed_or_break

  before_validation :normalize_phone

  def formatted_phone
    return nil unless phone.present?
    "(#{phone[0..2]})-#{phone[3..5]}-#{phone[6..9]}"
  end

  def duration_slots
    return 0 unless start_time && end_time
    ((end_time - start_time) / 15.minutes).to_i
  end

  private

  def normalize_phone
    self.phone = phone.gsub(/\D/, "") if phone.present?
  end

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

  def not_during_closed_or_break
    return unless date && start_time && end_time
    closed_sessions = MeetSession.where(date: date)
      .where(closed: true).or(MeetSession.where(date: date, break_period: true))
      .where("start_time < ? AND end_time > ?", end_time, start_time)
    if closed_sessions.exists?
      errors.add(:base, "Booking overlaps with a closed or break session")
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
