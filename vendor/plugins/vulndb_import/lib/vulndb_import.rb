# VulndbImport

require 'vulndb_import/meta'

module VulndbImport
  class Configuration < Core::Configurator
    configure :namespace => 'vulndb'
    setting  :host, :default => 'localhost'
    setting :port, :default => 3000
    setting :path, :default => '/vulnerabilities'
  end       
end

module Plugins
  module Import
    include VulndbImport
  end
end
