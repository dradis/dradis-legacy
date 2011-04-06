# SurecheckUpload

require 'surecheck_upload/filters'
require 'surecheck_upload/parser'
require 'surecheck_upload/meta'

module SurecheckUpload
  class Configuration < Core::Configurator
    configure :namespace => 'surecheck'
    setting :category, :default => 'SureCheck output'
    setting :author, :default => 'SureCheck plugin'
    setting :node_label, :default => 'SureCheck Output'
  end
end

# This includes the import plugin module in the dradis import plugin repository
module Plugins
  module Upload 
    include SurecheckUpload
  end
end
