# WxfUpload
require 'wxf_upload/parser'
require 'wxf_upload/filters'
require 'wxf_upload/meta'

module WxfUpload
  class Configuration < Core::Configurator
    configure :namespace => 'wxf'
    setting :category, :default => 'wXf output'
    setting :author, :default => 'wXf results'
    setting :node_label, :default => 'wXf Output'
  end
end

# This includes the import plugin module in the dradis import plugin repository
module Plugins
  module Upload 
    include WxfUpload
  end
end
