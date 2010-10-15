source 'http://rubygems.org'

gem 'rails', '3.0.0'

gem 'sqlite3-ruby', :require => 'sqlite3'
gem 'delayed_job'

# We need to make an exception for Windows. Otherwise Bundler is going to try 
# and fail to compile the RedCloth gem. If the gem is missing in your Windows
# environment (the installer should have taken care of it) you can use:
#   gem install RedCloth --platform=x86-mswin32-60 
#
if !( (RUBY_PLATFORM =~ /mswin/i) || (RUBY_PLATFORM =~ /mingw/i) )
  gem 'RedCloth', :require => 'redcloth'
end

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
# group :development, :test do
#   gem 'webrat'
# end
