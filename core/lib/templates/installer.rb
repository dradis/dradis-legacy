
# This application template is inspired by:
#   * https://github.com/refinery/refinerycms/blob/master/templates/refinery/installer.rb
#   * http://railswizard.org/
#   * https://github.com/RailsApps/rails-composer
#   * https://github.com/RailsApps/rails_apps_composer
#

# >----------------------------[ Initial Setup ]------------------------------<

# We want to ensure that you have an ExecJS runtime available!
begin
  run 'bundle install --quiet'
  require 'execjs'
  ::ExecJS::Runtimes.autodetect
rescue LoadError
  gsub_file 'Gemfile', "# gem 'therubyracer'", "gem 'therubyracer'"
end

# >---------------------------------[ Dradis ]--------------------------------<

# Dradis Framework gems
gem 'dradis', path: '/Users/etd/dradis/git/dradis'
gem 'dradis_core', path: '/Users/etd/dradis/git/dradis/core'
gem 'dradis-html_export', path: '/Users/etd/dradis/git/dradis-html_export'


# >-----------------------------[ Run Bundler ]-------------------------------<

run 'bundle install'
rake 'db:create'
generate "dradis:install #{ARGV.join(' ')}"

