# NexposeUpload

require 'nexpose_upload/filters'
require 'nexpose_upload/meta'

# This includes the import plugin module in the dradis import plugin repository

module NexposeUpload
  class Configuration < Core::Configurator
    configure :namespace => 'nexpose'
    setting :category, :default => 'NeXpose Scanner output'
    setting :author, :default => 'NeXpose Scanner plugin'
    setting :parent_node, :default => 'plugin.nexpose'
  end
end

module Plugins
  module Upload 
    include NexposeUpload
  end
end
