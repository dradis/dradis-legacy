source 'http://rubygems.org'

gem 'rails', '3.0.10'
gem 'jquery-rails'

gem 'builder'
gem 'nokogiri'

gem 'RedCloth', '4.2.8', :require => 'redcloth'
gem 'thor', '0.14.6'

if !( (RUBY_PLATFORM =~ /mswin/i) || (RUBY_PLATFORM =~ /mingw/i) )
  gem 'sqlite3-ruby', '1.2.5', :require => 'sqlite3'
else
  gem 'sqlite3', '1.3.3', :require => 'sqlite3'
end

# Gems required for testing
gem 'rspec-rails', :group => [:development, :test]

group :test do
  gem 'factory_girl'
  gem 'capybara'
  gem 'guard-rspec'
end
