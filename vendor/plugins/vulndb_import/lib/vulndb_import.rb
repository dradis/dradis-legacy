# VulndbImport

require 'vulndb_import/meta'

module VulndbImport
  module Filters
    def search
    end
  end
end

module Plugins
  module Import
    include VulndbImport
  end
end
