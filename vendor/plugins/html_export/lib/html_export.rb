# HtmlExport

require 'html_export/actions'
require 'html_export/version'

module HTMLExport
  CONF = {
    :template => File.join( RAILS_ROOT, 
                              'vendor', 'plugins', 'html_export', 
                              'template.html.erb' )
  }
end

# This includes the export plugin module in the dradis export plugin repository
module Plugins
  module Export
    include HTMLExport
  end
end
