ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all
  end
end

class ActionDispatch::IntegrationTest
  # Log in as a fixture user. Default password matches the users.yml fixture.
  def log_in_as(user, password: "password123")
    post login_path, params: { username: user.username, password: password }
  end
end
