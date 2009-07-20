# ProjectManagement

require 'project_management/exporter'
require 'project_management/actions'
require 'project_management/uploader/template'
require 'project_management/uploader/package'

module Plugins
  module Export
    include ProjectExport
  end
  module Upload
    include ProjectTemplateUpload
    include ProjectPackageUpload
  end
end
