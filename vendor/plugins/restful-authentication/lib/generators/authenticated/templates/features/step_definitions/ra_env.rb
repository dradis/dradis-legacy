
Before do
  Fixtures.reset_cache
  fixtures_folder = Rails.root.join('spec', 'fixtures')
  Fixtures.create_fixtures(fixtures_folder, "users")
end

# Make visible for testing
ApplicationController.send(:public, :logged_in?, :current_user, :authorized?)
