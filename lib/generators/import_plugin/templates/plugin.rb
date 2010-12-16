# <%= class_name %>

require '<%= file_name %>/filters'
require '<%= file_name %>/meta'

module <%= class_name %>
  CONF_FILE = Rails.root.join('config', '<%= file_name %>.yml')
  CONF = YAML::load( File.read CONF_FILE ) 
end

# This includes the import plugin module in the dradis import plugin repository
module Plugins
  module Import
    include <%= class_name %>
  end
end
