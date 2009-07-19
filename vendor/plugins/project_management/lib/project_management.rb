# ProjectManagement

require 'project_management/exporter'
require 'project_management/actions'
require 'project_management/uploader'

module Plugins
  module Export
    include ProjectExport
  end
  module Upload
    include ProjectTemplateUpload
  end
end
