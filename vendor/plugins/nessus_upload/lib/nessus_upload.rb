# NessusUploadImport

require 'nessus_upload/filters'
require 'nessus_upload/meta'

module NessusUpload
  class Configuration < Core::Configurator
    configure :namespace => 'nessus'
    setting :category, :default => 'Nessus output'
    setting :author, :default => 'Nessus plugin'
    setting :parent_node, :default => 'plugin.nessus'
  end
end

# This includes the upload plugin module in the dradis upload plugin repository
module Plugins
  module Upload
    include NessusUpload
  end
end
