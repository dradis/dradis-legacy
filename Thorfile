
# add the dradis core tasks, and define the namespaces for import, export, and
# upload tasks
require 'lib/tasks/thorfile'

# a plugin can add additional tasks to Thor by declaring tasks/thorfile.rb in
# its plugin directory - so we can keep a plugin's command line tasks bundled
# with the plugin
Dir.glob('vendor/plugins/*/lib/tasks/thorfile.rb').each do |thorfile|
  require thorfile
end
