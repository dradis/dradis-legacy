# <%= class_name %>

require '<%= file_name %>/filters'
require '<%= file_name %>/meta'

# This includes the import plugin module in the dradis import plugin repository
module Plugins
  module Import
    include <%= class_name %>
  end
end
