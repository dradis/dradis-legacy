# NessusUploadImport

require 'nessus_upload/filters'
require 'nessus_upload/meta'

# This includes the upload plugin module in the dradis upload plugin repository
module Plugins
  module Upload
    include NessusUpload
  end
end
