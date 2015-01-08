# For Bundler.with_clean_env
require 'bundler/setup'

PACKAGE_NAME = "dradisframework"
VERSION = "3.0.0"
TRAVELING_RUBY_VERSION = "20141215-2.1.5"

# Must match Gemfile:
SQLITE3_VERSION = "1.3.9"
NOKOGIRI_VERSION = "1.6.5"
BCRYPT_VERSION = "3.1.9"

desc "Package your app"
task :package => ['package:linux:x86', 'package:linux:x86_64', 'package:osx']

namespace :package do
  namespace :linux do
    task :x86 => [:bundle_install,
      # "assets:precompile",
      "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86.tar.gz",
      "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86-sqlite3-#{SQLITE3_VERSION}.tar.gz",
      "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86-nokogiri-#{NOKOGIRI_VERSION}.tar.gz",
      "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86-bcrypt-#{NOKOGIRI_VERSION}.tar.gz"
    ] do
      create_package("linux-x86")
    end

    desc "Package your app for Linux x86_64"
    task :x86_64 => [:bundle_install,
      # "assets:precompile",
      "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64.tar.gz",
      "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64-sqlite3-#{SQLITE3_VERSION}.tar.gz",
      "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64-nokogiri-#{NOKOGIRI_VERSION}.tar.gz",
      "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64-bcrypt-#{BCRYPT_VERSION}.tar.gz"
    ] do
      create_package("linux-x86_64")
    end
  end

  desc "Package your app for OS X"
  task :osx => [:bundle_install,
    # "assets:precompile",
    "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-osx.tar.gz",
    "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-osx-sqlite3-#{SQLITE3_VERSION}.tar.gz",
    "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-osx-nokogiri-#{NOKOGIRI_VERSION}.tar.gz",
    "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-osx-bcrypt-#{BCRYPT_VERSION}.tar.gz"
  ] do
    create_package("osx")
  end

 desc "Install gems to local directory"
  task :bundle_install do
    puts "\nRunning package:bundle_install..."
    if RUBY_VERSION !~ /^2\.1\./
      abort "You can only 'bundle install' using Ruby 2.1, because that's what Traveling Ruby uses."
    end

    puts "\nRecreating tmp directory..."
    sh "rm -rf packaging/tmp"
    sh "mkdir -p packaging/tmp"
    sh "mkdir -p packaging/tmp/engines/core"
    sh "mkdir -p packaging/tmp/engines/frontend"

    puts "\nInstalling gems..."
    sh "cp Gemfile packaging/tmp"
    sh "cp engines/core/dradis_core.gemspec packaging/tmp/engines/core"
    sh "cp engines/frontend/dradis_frontend.gemspec packaging/tmp/engines/frontend"

    Bundler.with_clean_env do
      sh "cd packaging/tmp && env BUNDLE_IGNORE_CONFIG=1 NOKOGIRI_USE_SYSTEM_LIBRARIES=1 PACKAGING=1 bundle install --path ../vendor --without development test"
    end

    puts "\nCleaning up cache and native extensions..."
    sh "rm -rf packaging/vendor/*/*/cache/*"
    sh "rm -rf packaging/vendor/ruby/*/extensions"
    sh "find packaging/vendor/ruby/*/gems -name '*.so' | xargs rm -f"
    sh "find packaging/vendor/ruby/*/gems -name '*.bundle' | xargs rm -f"
  end

end

file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86.tar.gz" do
  download_runtime("linux-x86")
end

file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64.tar.gz" do
  download_runtime("linux-x86_64")
end

file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-osx.tar.gz" do
  download_runtime("osx")
end

file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86-sqlite3-#{SQLITE3_VERSION}.tar.gz" do
  download_native_extension("linux-x86", "sqlite3-#{SQLITE3_VERSION}")
end

file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64-sqlite3-#{SQLITE3_VERSION}.tar.gz" do
  download_native_extension("linux-x86_64", "sqlite3-#{SQLITE3_VERSION}")
end

file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-osx-sqlite3-#{SQLITE3_VERSION}.tar.gz" do
  download_native_extension("osx", "sqlite3-#{SQLITE3_VERSION}")
end

file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86-nokogiri-#{NOKOGIRI_VERSION}.tar.gz" do
  download_native_extension("linux-x86", "nokogiri-#{NOKOGIRI_VERSION}")
end

file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64-nokogiri-#{NOKOGIRI_VERSION}.tar.gz" do
  download_native_extension("linux-x86_64", "nokogiri-#{NOKOGIRI_VERSION}")
end

file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-osx-nokogiri-#{NOKOGIRI_VERSION}.tar.gz" do
  download_native_extension("osx", "nokogiri-#{NOKOGIRI_VERSION}")
end

file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86-bcrypt-#{BCRYPT_VERSION}.tar.gz" do
  download_native_extension("linux-x86", "bcrypt-#{BCRYPT_VERSION}")
end

file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64-bcrypt-#{BCRYPT_VERSION}.tar.gz" do
  download_native_extension("linux-x86_64", "bcrypt-#{BCRYPT_VERSION}")
end

file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-osx-bcrypt-#{BCRYPT_VERSION}.tar.gz" do
  download_native_extension("osx", "bcrypt-#{BCRYPT_VERSION}")
end

def create_package(target)
  puts "\nCreating package #{ target }..."

  package_dir = "#{PACKAGE_NAME}-#{target}"

  puts "\nRecreating #{package_dir} directory..."
  sh "rm -rf #{package_dir}"
  sh "mkdir #{package_dir}"
  sh "mkdir -p #{package_dir}/lib/app"

  puts "\nCopying app..."
  sh "cp -r config.ru Rakefile Thorfile dradis bin app config lib public spec db vendor #{package_dir}/lib/app/"
  sh "rm -rf #{package_dir}/lib/app/vendor/cache #{package_dir}/lib/app/db/*.sqlite3"

  puts "\nPreparing database..."
  sh "cp config/database.yml.template config/database.yml"
  sh "RAILS_ENV=production thor dradis:setup:configure"
  sh "RAILS_ENV=production thor dradis:setup:migrate"
  sh "RAILS_ENV=production thor dradis:reset:database"
  sh "RAILS_ENV=production thor dradis:setup:seed"
  sh "cp db/production.sqlite3 #{package_dir}/lib/app/db/"

  puts "\nCopying ruby..."
  sh "mkdir #{package_dir}/lib/ruby"
  sh "tar -xzf packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-#{target}.tar.gz -C #{package_dir}/lib/ruby"

  puts "\nCopying wrapper scripts and vendor files..."
  sh "cp packaging/wrapper-common.sh #{package_dir}/lib"
  sh "cp packaging/dradis-webapp packaging/dradis-worker #{package_dir}"
  sh "cp -pR packaging/vendor #{package_dir}/lib/"

  puts "\nCopying gems..."
  sh "cp packaging/tmp/Gemfile packaging/tmp/Gemfile.lock #{package_dir}/lib/vendor/"
  sh "rm -rf packaging/tmp"
  sh "mkdir -p #{package_dir}/lib/vendor/engines"
  sh "cp -r engines/core #{package_dir}/lib/vendor/engines"
  sh "cp -r engines/frontend #{package_dir}/lib/vendor/engines"

  # Temporarily disable RedCloth
  # TODO: Remove when RedCloth packages are available
  File.write(f = "#{package_dir}/lib/vendor/engines/frontend/dradis_frontend.gemspec", File.read(f).gsub("s.add_dependency 'RedCloth'","# s.add_dependency 'RedCloth'"))
  File.write("#{package_dir}/lib/vendor/engines/frontend/lib/redcloth.rb", "class RedCloth;def initialize(*args);end;end")

  sh "mkdir #{package_dir}/lib/vendor/.bundle"
  sh "cp packaging/bundler-config #{package_dir}/lib/vendor/.bundle/config"
  sh "tar -xzf packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-#{target}-sqlite3-#{SQLITE3_VERSION}.tar.gz " +
    "-C #{package_dir}/lib/vendor/ruby"
  sh "tar -xzf packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-#{target}-nokogiri-#{NOKOGIRI_VERSION}.tar.gz " +
    "-C #{package_dir}/lib/vendor/ruby"
  sh "tar -xzf packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-#{target}-bcrypt-#{BCRYPT_VERSION}.tar.gz " +
    "-C #{package_dir}/lib/vendor/ruby"

  puts "\nPacking..."
  unless ENV['DIR_ONLY']
    sh "tar -czf #{package_dir}.tar.gz #{package_dir}"
    sh "rm -rf #{package_dir}"
  end
end

def download_runtime(target)
  puts "\nDownloading runtime #{ target }"
  sh "cd packaging && curl -L -O --fail " +
    "http://d6r77u77i8pq3.cloudfront.net/releases/traveling-ruby-#{TRAVELING_RUBY_VERSION}-#{target}.tar.gz"
end

def download_native_extension(target, gem_name_and_version)
  puts "\nDownloading native extension #{ target }"
  sh "curl -L --fail -o packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-#{target}-#{gem_name_and_version}.tar.gz " +
    "http://d6r77u77i8pq3.cloudfront.net/releases/traveling-ruby-gems-#{TRAVELING_RUBY_VERSION}-#{target}/#{gem_name_and_version}.tar.gz"
end
