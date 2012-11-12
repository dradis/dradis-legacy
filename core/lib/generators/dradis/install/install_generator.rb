# TODO:
#   - precompile assets
#   - switch to Production?
#     + config.serve_static_assets = true in Production
#     + config.assets.precompile += %w( banner.css dradis3.js dradis3.css )

require 'rails/generators'
require 'bundler'
require 'bundler/cli'

module Dradis
  class InstallGenerator < Rails::Generators::Base
    source_root Pathname.new(File.expand_path('../templates', __FILE__))

    def generate
      load_assets!
      webrick_ssl!
      mount!
      remove_assets!
      copy_migrations!
      tweak_production!
      migrate_and_seed!
      # precompile assets
    end

    protected

    def load_assets!
      insert_into_file 'app/assets/stylesheets/application.css', '*= require dradis/dradis_core', :before => "*= require_self"
      insert_into_file 'app/assets/javascripts/application.js', '//= require dradis/dradis_core', :before => "//= require_tree ."
    end

    # Generate SSL cert
    def cert_and_key!
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
    end

    # WEBrick with SSL and port 3004
    def webrick_ssl!
      # Generate SSL cert and key
      cert_and_key!

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
    end

    # Mount engine on /
    def mount!
      route "mount Dradis::Core::Engine, :at => '/'"
    end

    # Remove unused files created by Rails
    def remove_assets!
      remove_file 'public/index.html'
      remove_file 'app/assets/images/rails.png'
    end

    # Copy migrations and seed data
    def copy_migrations!
      rake 'dradis:install:migrations'
      # The default Rails seed.rb file contains instructions on what the file
      # is used for
      remove_file 'db/seeds.rb'
      copy_file File.expand_path('../../../../../db/seeds.rb',__FILE__), 'db/seeds.rb'
    end

    def tweak_production!
      # switch to Production?
      #     + config.serve_static_assets = true in Production
      #     + config.assets.precompile += %w( banner.css dradis3.js dradis3.css )
      # gsub_file env, "config.assets.compile = false", "config.assets.compile = true", :verbose => false
    end

    def migrate_and_seed!
      rake 'db:create db:migrate db:seed'
    end
  end
end