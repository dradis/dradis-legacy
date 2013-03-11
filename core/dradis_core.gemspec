# -*- encoding: utf-8 -*-
version = File.read(File.expand_path('../../DRADIS_VERSION', __FILE__)).strip

Gem::Specification.new do |gem|
  gem.platform      = Gem::Platform::RUBY
  gem.name          = 'dradis_core'
  gem.version       = version
  gem.summary       = %q{Core functionality for the Dradis Framework project}
  gem.description   = %q{Required dependency for Dradis Framework}
  gem.required_ruby_version = '>= 1.9.3'
  gem.license       = 'GPL-2'


  gem.authors       = 'Daniel Martin'
  gem.email         = '<etd@nomejortu.com>'
  gem.homepage      = 'http://dradisframework.org'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'acts_as_tree', '~> 1.1.0'
  gem.add_dependency 'rails', '~> 3.2.12'
  # gem.add_dependency 'backbone-on-rails'
  # gem.add_dependency 'bootstrap-sass'
end
