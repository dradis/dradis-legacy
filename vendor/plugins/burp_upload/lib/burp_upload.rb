# BurpUpload

require 'burp_upload/parser'
require 'burp_upload/filters'
require 'burp_upload/meta'

module BurpUpload
  class Configuration < Core::Configurator
    configure :namespace => 'burp'
    setting :category, :default => 'Burp Scanner output'
    setting :author, :default => 'Burp Scanner plugin'
  end
end

# This includes the import plugin module in the dradis import plugin repository
module Plugins
  module Upload 
    include BurpUpload
  end
end
