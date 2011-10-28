# ZapUpload

require 'zap_upload/filters'
require 'zap_upload/meta'

module ZapUpload
  class Configuration < Core::Configurator
    configure :namespace => 'zap_upload'
    setting :category, :default => 'ZAP output'
    setting :author, :default => 'ZAP plugin'
    setting :parent_node, :default => 'plugin.zap'
  end
end

# This includes the import plugin module in the dradis import plugin repository
module Plugins
  module Upload 
    include ZapUpload
  end
end
