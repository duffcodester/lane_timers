# Default admin user (change password after first login)
unless User.exists?(username: "admin")
  User.create!(username: "admin", password: "lanetimers", password_confirmation: "lanetimers", role: :admin)
  puts "Created default user: admin / lanetimers"
end

clubs = [
  { name: "Thunderbolts", abbreviation: "THDR", color: "#e74c3c", coach: "Mike Johnson", address: "123 Main St", phone: "555-0101", email: "thunder@example.com" },
  { name: "Wave Riders", abbreviation: "WAVE", color: "#3498db", coach: "Sarah Chen", address: "456 Oak Ave", phone: "555-0102", email: "waves@example.com" },
  { name: "Green Machine", abbreviation: "GREEN", color: "#27ae60", coach: "Tom Garcia", address: "789 Pine Rd", phone: "555-0103", email: "green@example.com" },
  { name: "Golden Eagles", abbreviation: "EAGLE", color: "#f39c12", coach: "Lisa Park", address: "321 Elm St", phone: "555-0104", email: "eagles@example.com" },
  { name: "Purple Storm", abbreviation: "STORM", color: "#9b59b6", coach: "Dan Wilson", address: "654 Maple Dr", phone: "555-0105", email: "storm@example.com" },
  { name: "Silver Sharks", abbreviation: "SHARK", color: "#95a5a6", coach: "Amy Roberts", address: "987 Cedar Ln", phone: "555-0106", email: "sharks@example.com" },
  { name: "Red Dragons", abbreviation: "DRAGN", color: "#c0392b", coach: "Chris Lee", address: "147 Birch Ct", phone: "555-0107", email: "dragons@example.com" },
  { name: "Blue Blazers", abbreviation: "BLAZE", color: "#2980b9", coach: "Karen Davis", address: "258 Walnut St", phone: "555-0108", email: "blazers@example.com" },
]

clubs.each do |attrs|
  Club.find_or_create_by!(name: attrs[:name]) do |club|
    club.assign_attributes(attrs.except(:name))
  end
end

puts "Seeded #{Club.count} clubs."

# Meet sessions for March 27-29, 2026 (8:00 AM – 8:00 PM)
dates = [Date.new(2026, 3, 27), Date.new(2026, 3, 28), Date.new(2026, 3, 29)]
session_names = ["Day 1 — Prelims", "Day 2 — Semifinals", "Day 3 — Finals"]
MeetSession.destroy_all
dates.each_with_index do |d, i|
  MeetSession.create!(
    date: d,
    name: session_names[i],
    start_time: Time.utc(2000, 1, 1, 8, 0),
    end_time: Time.utc(2000, 1, 1, 20, 0)
  )
end

puts "Seeded #{MeetSession.count} meet sessions."

# Sample bookings across March 27-29, 2026
all_clubs = Club.all.to_a
dates = [Date.new(2026, 3, 27), Date.new(2026, 3, 28), Date.new(2026, 3, 29)]

# Bookings from 10:00 AM to 5:00 PM (last booking at 4:00 PM, ends at 5:00 PM)
# Non-overlapping: place bookings at 1-hour intervals
bookings_data = [
  # March 27
  { date: dates[0], lane: 10, start: "10:00", club_idx: 0 },
  { date: dates[0], lane: 9,  start: "10:00", club_idx: 1 },
  { date: dates[0], lane: 8,  start: "11:00", club_idx: 2 },
  { date: dates[0], lane: 7,  start: "11:00", club_idx: 3 },
  { date: dates[0], lane: 6,  start: "12:00", club_idx: 4 },
  { date: dates[0], lane: 5,  start: "12:00", club_idx: 5 },
  { date: dates[0], lane: 4,  start: "13:00", club_idx: 6 },
  { date: dates[0], lane: 3,  start: "13:00", club_idx: 7 },
  { date: dates[0], lane: 10, start: "14:00", club_idx: 0 },
  { date: dates[0], lane: 9,  start: "14:00", club_idx: 1 },
  { date: dates[0], lane: 8,  start: "15:00", club_idx: 2 },
  { date: dates[0], lane: 7,  start: "15:00", club_idx: 3 },
  { date: dates[0], lane: 6,  start: "16:00", club_idx: 4 },
  { date: dates[0], lane: 5,  start: "16:00", club_idx: 5 },

  # March 28
  { date: dates[1], lane: 10, start: "10:00", club_idx: 2 },
  { date: dates[1], lane: 9,  start: "10:00", club_idx: 3 },
  { date: dates[1], lane: 8,  start: "10:30", club_idx: 4 },
  { date: dates[1], lane: 7,  start: "11:00", club_idx: 5 },
  { date: dates[1], lane: 6,  start: "11:15", club_idx: 6 },
  { date: dates[1], lane: 5,  start: "12:00", club_idx: 7 },
  { date: dates[1], lane: 4,  start: "12:15", club_idx: 0 },
  { date: dates[1], lane: 3,  start: "13:00", club_idx: 1 },
  { date: dates[1], lane: 10, start: "14:00", club_idx: 4 },
  { date: dates[1], lane: 9,  start: "14:30", club_idx: 5 },
  { date: dates[1], lane: 8,  start: "15:00", club_idx: 6 },
  { date: dates[1], lane: 7,  start: "15:15", club_idx: 7 },
  { date: dates[1], lane: 6,  start: "16:00", club_idx: 0 },
  { date: dates[1], lane: 5,  start: "16:00", club_idx: 1 },

  # March 29
  { date: dates[2], lane: 10, start: "10:00", club_idx: 6 },
  { date: dates[2], lane: 9,  start: "10:15", club_idx: 7 },
  { date: dates[2], lane: 8,  start: "11:00", club_idx: 0 },
  { date: dates[2], lane: 7,  start: "11:30", club_idx: 1 },
  { date: dates[2], lane: 6,  start: "12:00", club_idx: 2 },
  { date: dates[2], lane: 5,  start: "12:00", club_idx: 3 },
  { date: dates[2], lane: 4,  start: "13:00", club_idx: 4 },
  { date: dates[2], lane: 3,  start: "13:00", club_idx: 5 },
  { date: dates[2], lane: 10, start: "14:00", club_idx: 6 },
  { date: dates[2], lane: 9,  start: "14:00", club_idx: 7 },
  { date: dates[2], lane: 8,  start: "15:00", club_idx: 0 },
  { date: dates[2], lane: 7,  start: "15:30", club_idx: 1 },
  { date: dates[2], lane: 6,  start: "16:00", club_idx: 2 },
  { date: dates[2], lane: 5,  start: "16:00", club_idx: 3 },
]

Booking.destroy_all

bookings_data.each do |b|
  hour, min = b[:start].split(":").map(&:to_i)
  start = Time.utc(2000, 1, 1, hour, min)
  Booking.create!(
    date: b[:date],
    lane: b[:lane],
    start_time: start,
    end_time: start + 60.minutes,
    club: all_clubs[b[:club_idx]]
  )
end

puts "Seeded #{Booking.count} bookings."
