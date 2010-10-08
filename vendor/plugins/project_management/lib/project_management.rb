# ProjectManagement

require 'project_management/export/processor'
require 'project_management/export/meta_server_processor'
require 'project_management/actions'
require 'project_management/upload/template'
require 'project_management/upload/package'
require 'project_management/meta'

module ProjectManagement
  CONF_FILE = File.join(RAILS_ROOT, 'config', 'project_management.yml')
  CONF = YAML::load( File.read CONF_FILE )
end

module Plugins
  module Export
    include ProjectExport
  end
  module Upload
    include ProjectTemplateUpload
    include ProjectPackageUpload
  end
end
