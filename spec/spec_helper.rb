# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require File.expand_path("../factories", __FILE__)

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

# To ensure that Travis-CI engine can run the test suite we need
# to stablish an ActiveRecord connection even if we just have a
# template config
config_file = File.exists?( 'config/database.yml' ) ? 'config/database.yml' : 'config/database.yml.template'
ActiveRecord::Base.configurations = YAML.load_file( config_file )
ActiveRecord::Base.establish_connection('test')
ActiveRecord::Base.default_timezone = :utc

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  config.include(ControllerMacros, :type => :controller)

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true
end
