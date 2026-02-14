# Lane Timers

A lane booking application built with Rails 8. Teams can reserve lanes in 1-hour time slots across a visual scheduling grid.

## Features

- **10 lanes** available for booking (displayed 10 to 1)
- **Event dates** — bookings restricted to March 27-29, 2026
- **15-minute interval scheduling** from 8:00 AM to 10:00 PM (last booking starts at 9:00 PM)
- **1-hour bookings** that can start at any 15-minute mark (e.g., 12:15 PM - 1:15 PM)
- **Unlimited teams** with name, abbreviation (up to 5 chars), color, coach, address, phone, and email
- **Team abbreviations** displayed on the scheduling grid and booking modal for compact viewing
- **Visual scheduling grid** — click any empty slot to book, click a booking to remove it
- **Overlap prevention** — the system ensures no two bookings conflict on the same lane
- **Team admin** — full CRUD interface for managing teams at `/teams`
- **Booking hours tracking** — total booked hours displayed per team on the admin page
- **Date navigation** — browse schedules by date with prev/next buttons and a date picker

## Tech Stack

- Ruby 3.3.5
- Rails 8.1
- PostgreSQL
- Importmap (no Node.js required)
- Turbo/Stimulus

## Setup

```bash
rbenv install 3.3.5
rbenv local 3.3.5
bundle install
rails db:create
rails db:migrate
rails server
```

Visit `http://localhost:3000/teams` to create teams, then `http://localhost:3000` to start booking lanes.
