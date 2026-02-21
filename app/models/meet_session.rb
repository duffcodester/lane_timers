class MeetSession < ApplicationRecord
  belongs_to :meet, optional: true

  validates :date, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validate :end_time_after_start_time
  validate :no_overlapping_sessions

  def time_slots
    slots = []
    current = start_time
    while current < end_time
      slots << [current.hour, current.min]
      current += 15.minutes
    end
    slots
  end

  private

  def end_time_after_start_time
    return unless start_time && end_time
    if end_time <= start_time
      errors.add(:end_time, "must be after start time")
    end
  end

  def no_overlapping_sessions
    return unless date && start_time && end_time
    scope = MeetSession.where(date: date)
      .where("start_time < ? AND end_time > ?", end_time, start_time)
    scope = scope.where.not(id: id) if persisted?
    if scope.exists?
      errors.add(:base, "This session overlaps with an existing session on this date")
    end
  end
end
