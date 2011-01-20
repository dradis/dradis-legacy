# OsvdbImport

require 'osvdb'
require 'osvdb_import/filters'
require 'osvdb_import/meta'


module OSVDBImport
  # Please register an account in the OSVDB site to get your API key. Steps:
  #   1. Create the account: http://osvdb.org/account/signup
  #   2. Find your key in http://osvdb.org/api
  class Configuration < Core::Configurator
    configure     :namespace => 'osvdb'
    setting       :api_key, :default => "<your_API_key>"
  end
  
  BAD_API_KEY = '<your_API_key>'
end
 
# This includes the import plugin module in the dradis import plugin repository
module Plugins
  module Import
    include OSVDBImport
  end
end
