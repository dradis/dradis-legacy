require File.expand_path("../../../../../config/environment", __FILE__)

RSpec.configure do |config|
  config.color_enabled = true
  # Use the specified formatter
  config.formatter = :documentation
end