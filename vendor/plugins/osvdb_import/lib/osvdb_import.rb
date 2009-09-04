# OsvdbImport

require 'osvdb_import/filters'
require 'osvdb_import/meta'

# This includes the import plugin module in the dradis import plugin repository
module Plugins
  module Import
    include OSVDBImport
  end
end
