class MeetSession < ApplicationRecord
  validates :date, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validate :end_time_after_start_time

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
end
