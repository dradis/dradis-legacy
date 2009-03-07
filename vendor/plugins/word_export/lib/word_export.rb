# WordExport

require 'word_export/processor'
require 'word_export/actions'

module WordExport
  REPORTING_CATEGORY_NAME = 'WordExport ready'
end

module Plugins
  module Export
    include WordExport
  end
end
