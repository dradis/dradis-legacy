# <%= class_name %>

require '<%= file_name %>/filters'
require '<%= file_name %>/meta'

module <%= class_name %>
  class Configuration < Core::Configurator
    configure :namespace => '<%= class_name.underscore %>'

    # setting :my_setting, :default => 'Something'
    # setting :another, :default => 'Something Else'
  end
end

# This includes the upload plugin module in the Dradis upload plugin repository
module Plugins
  module Upload 
    include <%= class_name %>
  end
end
