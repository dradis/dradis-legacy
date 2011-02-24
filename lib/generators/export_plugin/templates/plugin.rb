# <%= class_name %>

require '<%= file_name %>/actions'
require '<%= file_name %>/version'

module <%= class_name %>
  class Configuration < Core::Configurator
    configure :namespace => '<%= class_name.underscore %>'
  
    # setting :my_setting, :default => 'Something'
    # setting :another, :default => 'Something Else'
  end

  module Actions
    # first action
    def to_myformat(params={})
      # your action code to do the export goes here
      render :type => 'text/html', :text => '<html><body><h1>Sample Export Plugin</h1>' + 
                      '<p>This method does not define any format.</p>' +
                      "<p>Find me at: <code>#{__FILE__}</code></p>"
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
