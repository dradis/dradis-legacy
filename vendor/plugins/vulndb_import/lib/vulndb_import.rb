# VulndbImport

require 'vulndb_import/meta'

module VulndbImport
  module Filters
    module TextSearch
      def self.description
      end
      def self.run(params={}) 
      end
    end
  end
end

module Plugins
  module Import
    include VulndbImport
  end
end
