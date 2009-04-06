# <%= class_name %>

require '<%= file_name %>/meta'

module <%= class_name %>
  module Filters
    # complete this with the filter code for the import plugin
  end
end

# This includes the import plugin module in the dradis import plugin repository
module Plugins
  module Import
    include <%= class_name %>
  end
end
