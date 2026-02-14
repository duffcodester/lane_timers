teams = [
  { name: "Thunderbolts", abbreviation: "THDR", color: "#e74c3c", coach: "Mike Johnson", address: "123 Main St", phone: "555-0101", email: "thunder@example.com" },
  { name: "Wave Riders", abbreviation: "WAVE", color: "#3498db", coach: "Sarah Chen", address: "456 Oak Ave", phone: "555-0102", email: "waves@example.com" },
  { name: "Green Machine", abbreviation: "GREEN", color: "#27ae60", coach: "Tom Garcia", address: "789 Pine Rd", phone: "555-0103", email: "green@example.com" },
  { name: "Golden Eagles", abbreviation: "EAGLE", color: "#f39c12", coach: "Lisa Park", address: "321 Elm St", phone: "555-0104", email: "eagles@example.com" },
  { name: "Purple Storm", abbreviation: "STORM", color: "#9b59b6", coach: "Dan Wilson", address: "654 Maple Dr", phone: "555-0105", email: "storm@example.com" },
  { name: "Silver Sharks", abbreviation: "SHARK", color: "#95a5a6", coach: "Amy Roberts", address: "987 Cedar Ln", phone: "555-0106", email: "sharks@example.com" },
  { name: "Red Dragons", abbreviation: "DRAGN", color: "#c0392b", coach: "Chris Lee", address: "147 Birch Ct", phone: "555-0107", email: "dragons@example.com" },
  { name: "Blue Blazers", abbreviation: "BLAZE", color: "#2980b9", coach: "Karen Davis", address: "258 Walnut St", phone: "555-0108", email: "blazers@example.com" },
]

teams.each do |attrs|
  Team.find_or_create_by!(name: attrs[:name]) do |team|
    team.assign_attributes(attrs.except(:name))
  end
end

puts "Seeded #{Team.count} teams."
