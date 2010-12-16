# HtmlExport

require 'html_export/actions'
require 'html_export/version'

module HTMLExport
  REPORTING_CATEGORY_NAME = 'HTMLExport ready'
  CONF = {
    :template => Rails.root.join( 'vendor', 'plugins', 'html_export', 'template.html.erb' )
  }
end

# This includes the export plugin module in the dradis export plugin repository
module Plugins
  module Export
    include HTMLExport
  end
end
