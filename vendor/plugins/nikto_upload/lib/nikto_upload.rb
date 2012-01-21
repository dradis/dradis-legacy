# NiktoUpload

require 'nikto_upload/filters'
require 'nikto_upload/meta'

module NiktoUpload
  class Configuration < Core::Configurator
    configure :namespace => 'nikto_upload'

    # name of the note cateory that is created
    setting :category, :default => "Nikto output"
    
    # name of the author
    setting :author, :default => "Nikto plugin"
    
    # name of the node that will be created in your repository tree that will be ancestor to all plugin-generated content
    setting :parent_node, :default => "Nikto scan"
  end
end

# This includes the upload plugin module in the Dradis upload plugin repository
module Plugins
  module Upload 
    include NiktoUpload
  end
end
