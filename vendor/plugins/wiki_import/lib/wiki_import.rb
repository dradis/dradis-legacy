# WikiImport

require 'wiki_import/filters'
require 'wiki_import/meta'

module WikiImport
end

module Plugins
  module Import
    include WikiImport
  end
end
