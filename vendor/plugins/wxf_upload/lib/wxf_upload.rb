# WxfUpload
require 'wxf_upload/parser'
require 'wxf_upload/filters'
require 'wxf_upload/meta'


# This includes the import plugin module in the dradis import plugin repository
module Plugins
  module Upload 
    include WxfUpload
  end
end
