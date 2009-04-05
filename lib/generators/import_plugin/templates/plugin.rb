# <%= class_name %>

require '<%= file_name %>/actions'
require '<%= file_name %>/version'

module <%= class_name %>
  module Actions
    # first action
    def to_myformat(params={})
      # your action code to do the export goes here
    end

    # second action
    # [...]
  end
end

# This includes the export plugin module in the dradis export plugin repository
module Plugins
  module Export
    include <%= class_name %>
  end
end