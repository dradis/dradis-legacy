# BurpUpload

require 'burp_upload/filters'
require 'burp_upload/meta'

# This includes the import plugin module in the dradis import plugin repository
module Plugins
  module Upload 
    include BurpUpload
  end
end
