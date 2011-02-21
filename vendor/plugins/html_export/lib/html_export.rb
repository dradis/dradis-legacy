# HtmlExport

require 'html_export/actions'
require 'html_export/version'

module HTMLExport
  class Configuration < Core::Configurator
    configure :namespace => 'htmlexport'
    setting :category, :default => 'HTMLExport ready'
    setting :template, :default => Rails.root.join( 'vendor', 'plugins', 'html_export', 'template.html.erb' )
  end
end

# This includes the export plugin module in the dradis export plugin repository
module Plugins
  module Export
    include HTMLExport
  end
end
