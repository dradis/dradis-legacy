# ProjectManagement

require 'project_management/export/processor'
require 'project_management/export/meta_server_processor'
require 'project_management/actions'
require 'project_management/upload/template'
require 'project_management/upload/package'
require 'project_management/meta'

module ProjectManagement
  class Configuration < Core::Configurator
    configure     :namespace => 'project'
    setting       :ms_host, :default => 'localhost'
    setting       :ms_port, :default => 3000
    setting       :ms_user, :default => 'etd'
    setting       :ms_password, :default => 'etd001'
  end
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
