# TyphonUpload

require 'typhon_upload/filters'
require 'typhon_upload/meta'

# This includes the import plugin module in the dradis import plugin repository
module Plugins
  module Upload 
    include TyphonUpload
  end
end
