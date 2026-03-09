require "test_helper"

# Verifies that every protected route redirects unauthenticated visitors to
# the login page, and that the login/logout flow itself works correctly.
class AuthenticationTest < ActionDispatch::IntegrationTest
  # -----------------------------------------------------------------------
  # Helpers
  # -----------------------------------------------------------------------

  LOGIN_REDIRECT = "/login"

  def assert_requires_login
    assert_redirected_to LOGIN_REDIRECT
  end

  # -----------------------------------------------------------------------
  # Sessions — login/logout (NOT protected)
  # -----------------------------------------------------------------------

  test "login page is accessible without authentication" do
    get login_path
    assert_response :ok
  end

  test "login with valid credentials redirects to root" do
    log_in_as users(:alice)
    assert_redirected_to root_path
  end

  test "login with wrong password stays on login page" do
    post login_path, params: { username: users(:alice).username, password: "wrongpassword" }
    assert_response :unprocessable_entity
  end

  test "login with unknown username stays on login page" do
    post login_path, params: { username: "nobody", password: "password123" }
    assert_response :unprocessable_entity
  end

  test "logout redirects to login page" do
    log_in_as users(:alice)
    get logout_path
    assert_redirected_to login_path
  end

  test "after logout, protected pages redirect to login" do
    log_in_as users(:alice)
    get logout_path
    get root_path
    assert_requires_login
  end

  # -----------------------------------------------------------------------
  # Schedule / Bookings
  # -----------------------------------------------------------------------

  test "schedule index requires authentication" do
    get root_path
    assert_requires_login
  end

  test "schedule index is accessible when authenticated" do
    log_in_as users(:alice)
    get root_path
    assert_response :ok
  end

  test "bookings list requires authentication" do
    get list_bookings_path
    assert_requires_login
  end

  test "bookings list is accessible when authenticated" do
    log_in_as users(:alice)
    get list_bookings_path
    assert_response :ok
  end

  test "create booking requires authentication" do
    post bookings_path, params: { booking: { lane: 5, date: "2026-03-27",
                                             start_time: "10:00", end_time: "11:00" } }
    assert_requires_login
  end

  test "update booking requires authentication" do
    patch booking_path(bookings(:first)), params: { booking: { lane: 6 } }
    assert_requires_login
  end

  test "delete booking requires authentication" do
    delete booking_path(bookings(:first))
    assert_requires_login
  end

  test "clear bookings requires authentication" do
    delete clear_bookings_path, params: { date: "2026-03-27" }
    assert_requires_login
  end

  # -----------------------------------------------------------------------
  # Clubs
  # -----------------------------------------------------------------------

  test "clubs index requires authentication" do
    get clubs_path
    assert_requires_login
  end

  test "clubs index is accessible when authenticated" do
    log_in_as users(:alice)
    get clubs_path
    assert_response :ok
  end

  test "new club form requires authentication" do
    get new_club_path
    assert_requires_login
  end

  test "club show requires authentication" do
    get club_path(clubs(:sharks))
    assert_requires_login
  end

  test "club edit form requires authentication" do
    get edit_club_path(clubs(:sharks))
    assert_requires_login
  end

  test "create club requires authentication" do
    post clubs_path, params: { club: { name: "New Club", color: "#ff0000" } }
    assert_requires_login
  end

  test "update club requires authentication" do
    patch club_path(clubs(:sharks)), params: { club: { name: "Updated" } }
    assert_requires_login
  end

  test "delete club requires authentication" do
    delete club_path(clubs(:sharks))
    assert_requires_login
  end

  test "export clubs requires authentication" do
    get export_clubs_path
    assert_requires_login
  end

  test "import clubs requires authentication" do
    post import_clubs_path, params: { file: "" }
    assert_requires_login
  end

  # -----------------------------------------------------------------------
  # Meet Sessions
  # -----------------------------------------------------------------------

  test "meet sessions index requires authentication" do
    get meet_sessions_path
    assert_requires_login
  end

  test "meet sessions index is accessible when authenticated" do
    log_in_as users(:alice)
    get meet_sessions_path
    assert_response :ok
  end

  test "new meet session form requires authentication" do
    get new_meet_session_path
    assert_requires_login
  end

  test "meet session edit form requires authentication" do
    get edit_meet_session_path(meet_sessions(:day_one))
    assert_requires_login
  end

  test "create meet session requires authentication" do
    post meet_sessions_path, params: { meet_session: { date: "2026-04-01",
                                                       start_time: "08:00", end_time: "12:00" } }
    assert_requires_login
  end

  test "update meet session requires authentication" do
    patch meet_session_path(meet_sessions(:day_one)), params: { meet_session: { name: "Updated" } }
    assert_requires_login
  end

  test "delete meet session requires authentication" do
    delete meet_session_path(meet_sessions(:day_one))
    assert_requires_login
  end

  test "duplicate meet session requires authentication" do
    post duplicate_meet_session_path(meet_sessions(:day_one))
    assert_requires_login
  end

  # -----------------------------------------------------------------------
  # Settings
  # -----------------------------------------------------------------------

  test "updating clubs column settings requires authentication" do
    patch clubs_columns_setting_path, params: { columns: { name: true } },
                                      as: :json
    assert_requires_login
  end

  # -----------------------------------------------------------------------
  # Users
  # -----------------------------------------------------------------------

  test "users index requires authentication" do
    get users_path
    assert_requires_login
  end

  test "users index is accessible when authenticated" do
    log_in_as users(:alice)
    get users_path
    assert_response :ok
  end

  test "new user form requires authentication" do
    get new_user_path
    assert_requires_login
  end

  test "create user requires authentication" do
    post users_path, params: { user: { username: "newguy", password: "secret123",
                                       password_confirmation: "secret123" } }
    assert_requires_login
  end

  test "delete user requires authentication" do
    delete user_path(users(:bob))
    assert_requires_login
  end

  # -----------------------------------------------------------------------
  # Meets
  # -----------------------------------------------------------------------

  test "meets index requires authentication" do
    get meets_path
    assert_requires_login
  end

  test "meets index is accessible when authenticated" do
    log_in_as users(:alice)
    get meets_path
    assert_response :ok
  end

  test "new meet form requires authentication" do
    get new_meet_path
    assert_requires_login
  end

  test "meet edit form requires authentication" do
    get edit_meet_path(meets(:spring_invitational))
    assert_requires_login
  end

  test "create meet requires authentication" do
    post meets_path, params: { meet: { name: "Summer Classic" } }
    assert_requires_login
  end

  test "update meet requires authentication" do
    patch meet_path(meets(:spring_invitational)), params: { meet: { name: "Updated" } }
    assert_requires_login
  end

  test "delete meet requires authentication" do
    delete meet_path(meets(:spring_invitational))
    assert_requires_login
  end

  # -----------------------------------------------------------------------
  # Cross-cutting: session survives across requests
  # -----------------------------------------------------------------------

  test "authenticated session persists across multiple requests" do
    log_in_as users(:alice)
    get root_path
    assert_response :ok
    get clubs_path
    assert_response :ok
    get meet_sessions_path
    assert_response :ok
    get users_path
    assert_response :ok
  end
end
