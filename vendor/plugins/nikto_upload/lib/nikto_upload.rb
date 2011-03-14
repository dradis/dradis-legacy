# NiktoUpload

require 'nikto_upload/parser'
require 'nikto_upload/filters'
require 'nikto_upload/meta'

module NiktoUpload
  class Configuration < Core::Configurator
    configure :namespace => 'nikto'
    setting :category, :default => 'Nikto Scanner output'
    setting :author, :default => 'Nikto Scanner plugin'
  end
end



# This includes the import plugin module in the dradis import plugin repository
module Plugins
  module Upload 
    include NiktoUpload
  end
end
