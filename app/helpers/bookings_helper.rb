module BookingsHelper
  def format_time(hour, min)
    ampm = hour >= 12 ? "PM" : "AM"
    h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour)
    "#{h}:#{min.to_s.rjust(2, '0')} #{ampm}"
  end
end
