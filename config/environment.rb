# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Uncomment to really force rails into production mode. See:
#   ./vendor/rails/railties/lib/commands/servers/webrick.rb#56
#ENV["RAILS_ENV"] = 'production'
#RAILS_ENV.replace('production') if defined?(RAILS_ENV)


# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION


# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # FIX from http://robsanheim.com/2008/01/08/rails-observers-make-rake-dbmigrate-crash-from-version-0/
  # to prevent rake db tasks from loading the observer (uses the 
  # 'configurations' table not available until revision 4)
  if (
       (File.basename($0) == 'rake') && 
       (%w{create drop migrate reset}.any? { |task| ARGV.include?("db:#{task}")||ARGV.include?("dradis:#{task}") })
     ) 
    # Running rake, disable import/export plugins. See r874
    # http://dradis.svn.sourceforge.net/viewvc/dradis/server/trunk/config/environment.rb?view=log#rev874
    # 
    # At least include the project_management plugin that will allow us to 
    # create a project package (for backup) and is known not to interact with 
    # the DB
    config.plugins = [:acts_as_tree, :project_management ]
  else
    config.active_record.observers = :revision_observer 
  end

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de

end
