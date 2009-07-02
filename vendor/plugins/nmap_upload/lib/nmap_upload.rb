# NmapUploadImport

require 'nmap_upload/filters'
require 'nmap_upload/meta'

# This includes the upload plugin module in the dradis upload plugin repository
module Plugins
  module Upload
    include NmapUpload
  end
end
