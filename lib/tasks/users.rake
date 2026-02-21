namespace :users do
  desc "Create a new user: rake users:create USERNAME=foo PASSWORD=bar"
  task create: :environment do
    username = ENV["USERNAME"] or abort "Usage: rake users:create USERNAME=foo PASSWORD=bar"
    password = ENV["PASSWORD"] or abort "Usage: rake users:create USERNAME=foo PASSWORD=bar"
    user = User.new(username: username, password: password, password_confirmation: password)
    if user.save
      puts "Created user: #{user.username}"
    else
      puts "Error: #{user.errors.full_messages.join(', ')}"
    end
  end

  desc "List all users"
  task list: :environment do
    User.order(:username).each { |u| puts u.username }
  end

  desc "Delete a user: rake users:delete USERNAME=foo"
  task delete: :environment do
    username = ENV["USERNAME"] or abort "Usage: rake users:delete USERNAME=foo"
    user = User.find_by(username: username.downcase)
    if user
      user.destroy
      puts "Deleted user: #{username}"
    else
      puts "User not found: #{username}"
    end
  end

  desc "Change a user's password: rake users:passwd USERNAME=foo PASSWORD=newpass"
  task passwd: :environment do
    username = ENV["USERNAME"] or abort "Usage: rake users:passwd USERNAME=foo PASSWORD=newpass"
    password = ENV["PASSWORD"] or abort "Usage: rake users:passwd USERNAME=foo PASSWORD=newpass"
    user = User.find_by(username: username.downcase)
    if user
      if user.update(password: password, password_confirmation: password)
        puts "Password updated for: #{user.username}"
      else
        puts "Error: #{user.errors.full_messages.join(', ')}"
      end
    else
      puts "User not found: #{username}"
    end
  end
end
