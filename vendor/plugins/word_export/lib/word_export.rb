# WordExport

require 'word_export/processor'
require 'word_export/actions'

module Plugins
  module Export
    include WordExport::Actions
  end
end
