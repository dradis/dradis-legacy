# NiktoUpload

require 'nikto_upload/parser'
require 'nikto_upload/filters'
require 'nikto_upload/meta'

# This includes the import plugin module in the dradis import plugin repository
module Plugins
  module Upload 
    include NiktoUpload
  end
end
