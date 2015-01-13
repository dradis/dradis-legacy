$:.push File.expand_path('../lib', __FILE__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.platform      = Gem::Platform::RUBY
  s.name = 'dradis_frontend'
  s.version = '3.0.0'
  s.summary = 'Front-end controllers/views for the Dradis Framework project.'
  s.description = 'Required dependency for Dradis Framework.'

  s.license = 'GPL-2'

  s.authors = ['Daniel Martin']
  s.email = ['etd@nomejortu.com']
  s.homepage = 'http://dradisframework.org'

  s.files = Dir['**/*'].keep_if { |file| File.file?(file) }
  s.executables = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  s.add_dependency 'rails', '~> 4.1.1'

  # User passwords
  s.add_dependency 'bcrypt', '~> 3.1.7'

  # Theme / CSS framework
  s.add_dependency 'bootstrap-sass', '~> 2.3.2.2'

  # Note markup
  s.add_dependency 'rails_autolink', '~> 1.1'
  s.add_dependency 'RedCloth', '4.2.9'

  # Forms that integrate with Twitter's Bootstrap
  s.add_dependency 'simple_form', '~> 3.0'

  # Authentication
  s.add_dependency 'warden', '~> 1.2.3'
end
