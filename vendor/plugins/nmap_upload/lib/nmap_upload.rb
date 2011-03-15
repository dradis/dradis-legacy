# NmapUploadImport

require 'nmap_upload/filters'
require 'nmap_upload/meta'

module NmapUpload
  class Configuration < Core::Configurator
    configure :namespace => 'nmap'
    setting :category, :default => 'Nmap output'
    setting :author, :default => 'Nmap plugin'
  end
end

# This includes the upload plugin module in the dradis upload plugin repository
module Plugins
  module Upload
    include NmapUpload
  end
end
