# W3afUpload

require 'w3af_upload/parser'
require 'w3af_upload/filters'
require 'w3af_upload/meta'

# This includes the import plugin module in the dradis import plugin repository

module W3afUpload
  class Configuration < Core::Configurator
    configure :namespace => 'w3af'
    setting :category, :default => 'w3af Scanner output'
    setting :author, :default => 'w3af Scanner plugin'
    setting :node_label, :default => 'w3af Output'
  end
end


module Plugins
  module Upload 
    include W3afUpload
  end
end
