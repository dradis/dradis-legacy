source 'http://rubygems.org'

gem 'rails', '3.0.4'

gem 'RedCloth', '4.2.5', :require => 'redcloth'

if !( (RUBY_PLATFORM =~ /mswin/i) || (RUBY_PLATFORM =~ /mingw/i) )
  gem 'sqlite3-ruby', '1.2.5', :require => 'sqlite3'
else
  gem 'sqlite3-ruby', '1.3.2', :require => 'sqlite3'
end

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
# group :development, :test do
#   gem 'webrat'
# end
