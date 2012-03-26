ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../../../../config/environment", __FILE__)
require 'rspec/rails'

RSpec.configure do |config|
  config.color_enabled = true
  # Use the specified formatter
  config.formatter = :documentation

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  config.before(:suite) do
    Configuration.create(:name=>'revision', :value=>'0')
    Configuration.create(:name=>'uploads_node', :value=>'Uploaded files')
  end
end