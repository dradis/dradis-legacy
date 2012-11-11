# TODO:
#   - ./db/seeds.rb
#   - copy migrations / create db / run migrations / seed data
#   - precompile assets
#   - switch to Production?
#     + config.serve_static_assets = true in Production
#     + config.assets.precompile += %w( banner.css dradis3.js dradis3.css )



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

# WEBrick with SSL and port 3004
inject_into_file 'script/rails', :after => '# This command will automatically be run when you run "rails" with Rails 3 gems installed from the root of your application.' do
  <<-eos

require 'rubygems'
require 'rails/commands/server'
require 'rack'
require 'webrick'
require 'webrick/https'

module Rails
  class Server < ::Rack::Server
    def default_options
      super.merge({
        :Port => 3004,
        :Host => "127.0.0.1",
        # hopefully this closes #17
        # ref: http://stackoverflow.com/questions/1156759/
        :DoNotReverseLookup => nil,
        :environment => (ENV['RAILS_ENV'] || "development").dup,
        :daemonize => false,
        :debugger => false,
        :pid => File.expand_path("tmp/pids/server.pid"),
        :config => File.expand_path("config.ru"),
        :SSLEnable => true,
        :SSLVerifyClient => OpenSSL::SSL::VERIFY_NONE,
        :SSLPrivateKey => OpenSSL::PKey::RSA.new(
               File.open(File.expand_path( '../../config/ssl/server.key.insecure', __FILE__)).read),
        :SSLCertificate => OpenSSL::X509::Certificate.new(
               File.open(File.expand_path('../../config/ssl/server.crt', __FILE__)).read),
        :SSLCertName => [["CN", WEBrick::Utils::getservername]]
      })
    end
  end
end
  eos
end

# Generate SSL cert

key = OpenSSL::PKey::RSA.generate(2048)
create_file 'config/ssl/server.key.insecure', key.export

cert = OpenSSL::X509::Certificate.new
cert.version = 2
cert.serial = 1
cert.subject = OpenSSL::X509::Name.parse "/C=GB/ST=London/O=Dradis Framework [dradisframework.org]/OU=Dradis server/CN=dradis"
cert.issuer = cert.subject
cert.public_key = key.public_key
cert.not_before = Time.now
cert.not_after = cert.not_before + 2 * 365 * 24 * 60 * 60 # 2 years validity
cert.sign(key, OpenSSL::Digest::SHA256.new)
create_file 'config/ssl/server.crt', cert.to_pem

# Mount engine on /
route "mount Dradis::Core::Engine, :at => '/'"

# Remove unused files created by Rails
remove_file 'public/index.html'
remove_file 'app/assets/images/rails.png'


#   - ./db/seeds.rb
#   - copy migrations / create db / run migrations / seed data
#   - precompile assets

# switch to Production?
#     + config.serve_static_assets = true in Production
#     + config.assets.precompile += %w( banner.css dradis3.js dradis3.css )


# >-----------------------------[ Run Bundler ]-------------------------------<


# inside do
#   run 'bundle install --path vendor/bundle'
# end


# rake 'db:create'
# generate "refinery:cms --fresh-installation #{ARGV.join(' ')}"


# >----------------------------[ Shell scripts ]------------------------------<

# TODO: check if in *NIX environmet (curl, chmod)
#for script in ['reset.sh', 'start.sh']
#  run "curl -O https://raw.github.com/dradis/meta/master/#{script}"
#  run "chmod +x "
#end