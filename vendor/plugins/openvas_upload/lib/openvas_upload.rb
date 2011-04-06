# OpenvasUpload

require 'openvas_upload/filters'
require 'openvas_upload/meta'

# This includes the import plugin module in the dradis import plugin repository

module OpenvasUpload
  class Configuration < Core::Configurator
    configure :namespace => 'openvas'
    setting :category, :default => 'OpenVAS Scanner output'
    setting :author, :default => 'OpenVAS Scanner plugin'
    setting :node_label, :default => 'OpenVAS Output'
  end
end

module Plugins
  module Upload 
    include OpenvasUpload
  end
end
