source 'http://rubygems.org'

gem 'rails', '3.0.3'

# gem 'delayed_job'

# We need to make an exception for Windows. Otherwise Bundler is going to try 
# and fail to compile the RedCloth gem. If the gem is missing in your Windows
# environment (the installer should have taken care of it) you can use:
#   gem install RedCloth --pre
#
gem 'RedCloth', '4.2.4.pre3', :require => 'redcloth'
gem 'thor', '0.14.6'

if !( (RUBY_PLATFORM =~ /mswin/i) || (RUBY_PLATFORM =~ /mingw/i) )
  gem 'sqlite3-ruby', '1.2.5', :require => 'sqlite3'
else
  gem 'sqlite3-ruby', '1.3.2', :require => 'sqlite3'
end

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development, :test do
  gem 'rspec-rails'
  gem 'factory_girl'
#   gem 'webrat'
end
