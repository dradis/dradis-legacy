# WordExport

require 'word_export/word_xml'
require 'word_export/processor'
require 'word_export/actions'
require 'word_export/version'

module WordExport
  REPORTING_CATEGORY_NAME = 'WordExport ready'
end

module Plugins
  module Export
    include WordExport
  end
end
