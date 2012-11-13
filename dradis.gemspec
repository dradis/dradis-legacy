version = File.read(File.expand_path('../DRADIS_VERSION',__FILE__)).strip

Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.name = 'dradis'
  s.version = version
  s.summary = 'Collaboration framework for security testing.'
  s.description = 'Dradis is an open source framework to enable effective information sharing, especially during security assessments.'

  s.required_ruby_version = '>= 1.9.3'
  s.required_rubygems_version = ">= 1.8.11"
  s.license = 'GPL-2'

  s.author = 'Daniel Martin'
  s.email = 'daniel@securityroots.com'
  s.homepage = 'http://dradisframework.org'

  s.bindir = 'bin'
  s.executables = []
  # s.files = Dir['guides/**/*']

  s.add_dependency('dradis_core', version)
end
