# RetinaUpload

require 'retina_upload/filters'
require 'retina_upload/meta'

module RetinaUpload
  class Configuration < Core::Configurator
    configure :namespace => 'retina'
    setting :category, :default => 'Retina Scanner Output'
    setting :author, :default => 'Retina Scanner Plugin'
    setting :node_label, :default => 'Retina Output'
  end
end

# This includes the import plugin module in the dradis import plugin repository
module Plugins
  module Upload 
    include RetinaUpload
  end
end
