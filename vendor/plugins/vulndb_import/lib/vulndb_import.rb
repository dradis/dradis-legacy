# VulndbImport

require 'vulndb_import/meta'

module VulndbImport
  module Filters
    module TextSearch
      NAME = 'Search for a specific value in all the fields of the DB'
      def self.run(params={}) 
        return [{ :title => 'Stub', :description => 'This content was returned by the server.' }]
      end
    end
  end
end

module Plugins
  module Import
    include VulndbImport
  end
end
