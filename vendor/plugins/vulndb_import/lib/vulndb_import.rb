# VulndbImport

require 'vulndb_import/filters'
require 'vulndb_import/meta'

module VulndbImport
  class Configuration < Core::Configurator
    configure :namespace => 'vulndb'
    setting :rest_url, :default => 'https://localhost/'
    setting :hq_rest_url, :default => 'https://youremail%40emaildomain.com:password@user.vulndbhq.com'
  end       

  class Page < ActiveResource::Base
    self.site = Configuration.rest_url
  end  
end

module Plugins
  module Import
    include VulndbImport
  end
end
