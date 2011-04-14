# VulndbImport

require 'vulndb_import/filters'
require 'vulndb_import/meta'

module VulndbImport
  class Configuration < Core::Configurator
    configure :namespace => 'vulndb'
    setting  :host, :default => 'localhost'
    setting :port, :default => 3000
    setting :path, :default => '/vulnerabilities'
  end       

  class Page < ActiveResource::Base
    self.site = "https://#{Configuration.host}:#{Configuration.port}#{Configuration.path}"
  end  
end

module Plugins
  module Import
    include VulndbImport
  end
end
