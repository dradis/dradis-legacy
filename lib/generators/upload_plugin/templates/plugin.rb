# <%= class_name %>

require '<%= file_name %>/filters'
require '<%= file_name %>/meta'

module <%= class_name %>
  class Configuration < Core::Configurator
    configure     :namespace => '<%= class_name.underscore %>'

    # setting       :my_setting, :default => 'Something'
    # setting       :another, :default => 'Something Else'
  end
end

# This includes the import plugin module in the dradis import plugin repository
module Plugins
  module Upload 
    include <%= class_name %>
  end
end
