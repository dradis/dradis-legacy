source 'https://rubygems.org'

group :development do
  gem 'sqlite3'
end

group :test do
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'capybara'
  gem 'guard-rspec', '~> 0.5.0'
  gem 'rspec-rails', '~> 2.9.0'
end

gemspec
