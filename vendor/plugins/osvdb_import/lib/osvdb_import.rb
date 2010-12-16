# OsvdbImport

require 'osvdb'
require 'osvdb_import/filters'
require 'osvdb_import/meta'


module OSVDBImport  
  BAD_API_KEY = '<your_API_key>'
  CONF_FILE = Rails.root.join('config', 'osvdb_import.yml')
  CONF = YAML::load( File.read CONF_FILE )
end
 
# This includes the import plugin module in the dradis import plugin repository
module Plugins
  module Import
    include OSVDBImport
  end
end
